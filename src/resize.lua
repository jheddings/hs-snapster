--- getTerminalDimensions(win)
--- Function
--- Returns the current rows and columns of the terminal window by querying
--- the PTY of its child shell process via stty.
---
--- Parameters:
---  * win - An hs.window object for the terminal window
---
--- Returns:
---  * rows, cols - The current terminal dimensions, or nil, nil on failure
local function getTerminalDimensions(win)
    local pid = win:application():pid()
    local tty = hs.execute(string.format(
        "ps -axo tt=,ppid= | awk '$2==%d && $1!=\"?\" {print $1; exit}'", pid
    )):match("^%s*(.-)%s*$")

    if not tty or tty == "" then return nil, nil end

    -- Query TIOCGWINSZ for both character and pixel dimensions.
    -- ws_xpixel/ws_ypixel give total content size in physical pixels,
    -- from which we can derive the true cell size independently of the
    -- (possibly stale) row/col count.
    local result = hs.execute(string.format(
        "python3 -c \"import fcntl,termios,struct; " ..
        "f=open('/dev/tty%s','rb'); " ..
        "w=struct.unpack('HHHH',fcntl.ioctl(f,termios.TIOCGWINSZ,b'\\\\0'*8)); " ..
        "print(w[0],w[1],w[2],w[3]); f.close()\"", tty))

    local rows, cols, xpx, ypx = result:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    rows, cols = tonumber(rows), tonumber(cols)
    xpx, ypx = tonumber(xpx), tonumber(ypx)

    if xpx and ypx and xpx > 0 and ypx > 0 and cols > 0 and rows > 0 then
        -- Convert physical pixels to logical pixels using display scale
        local scale = win:screen():currentMode().scale or 1
        local cell_w = (xpx / cols) / scale
        local cell_h = (ypx / rows) / scale
        spoon.Snapster.logger.i(string.format(
            "TIOCGWINSZ: %dx%d chars, %dx%d px, scale=%.1f => cell %.3fx%.3f",
            cols, rows, xpx, ypx, scale, cell_w, cell_h))
        return rows, cols, cell_w, cell_h
    end

    -- Fall back to character dimensions only
    return rows, cols
end

--- getScrollAreaHeight(win)
--- Function
--- Returns the height of the terminal's scroll area (AXScrollArea) via the
--- accessibility tree, used to exclude chrome (tab bar, etc.) from the
--- row height calculation.
---
--- Parameters:
---  * win - An hs.window object for the terminal window
---
--- Returns:
---  * The height of the scroll area, or nil if not found
--- getContentHeight(win)
--- Function
--- Returns the height of the terminal's content area via the accessibility
--- tree, used to exclude chrome (tab bar, etc.) from the row calculation.
--- Looks for AXScrollArea (traditional terminals) or a full-width AXGroup
--- (terminals like Ghostty that use a different AX structure).
---
--- Returns nil for terminals that use overlay chrome (e.g. Ghostty with
--- floating tab bar), since their PTY height equals the full frame height.
---
--- Parameters:
---  * win - An hs.window object for the terminal window
---
--- Returns:
---  * The height of the content area, or nil if not found / overlay chrome
local function getContentHeight(win)
    local ok, axapp = pcall(hs.axuielement.applicationElement, win:application())
    if not ok or not axapp then return nil end

    local winFrame = win:frame()
    for _, axwin in ipairs(axapp:attributeValue("AXWindows") or {}) do
        local f = axwin:attributeValue("AXFrame")
        if f and math.abs(f.x - winFrame.x) < 2 and math.abs(f.y - winFrame.y) < 2 then
            for _, child in ipairs(axwin:attributeValue("AXChildren") or {}) do
                local role = child:attributeValue("AXRole")
                local cf = child:attributeValue("AXFrame")
                -- AXScrollArea: traditional terminals (Terminal.app, iTerm2)
                -- Full-width AXGroup: other terminals with non-overlay tab bars
                if cf and (role == "AXScrollArea" or role == "AXGroup") and cf.w >= winFrame.w - 4 then
                    return cf.h
                end
            end
        end
    end
    return nil
end

--- FrameResizer
--- Class
--- Handles resizing of window frames based on a configuration.

--- FrameResizer:new(width, height)
--- Method
--- Creates a new FrameResizer instance.
---
--- Parameters:
---  * width - (optional) The fixed width to apply to windows
---  * height - (optional) The fixed height to apply to windows
---
--- Returns:
---  * A new FrameResizer instance

FrameResizer = LayoutOperation:new()
FrameResizer.__index = FrameResizer

function FrameResizer:new(width, height)
    local instance = {
        width = width or nil,
        height = height or nil,
    }
    return setmetatable(instance, self)
end

--- FrameResizer:apply(frame, context)
--- Method
--- Applies the resizing to the specified window frame.
---
--- Parameters:
---  * frame - The window frame to resize
---  * context - The context object containing the application information
---
--- Returns:
---  * The modified frame
---
--- Notes:
---  * The resizing is based on the effective configuration of the application.
function FrameResizer:apply(frame, context)
    local app = context:application()

    local logger = spoon.Snapster.logger
    local config = spoon.Snapster:getEffectiveConfig(app)

    logger.d("FrameResizer:apply(", self.width, ", ", self.height, ")")

    if config and (config.rows or config.cols) then
        local cur_rows, cur_cols, cell_w, cell_h = getTerminalDimensions(context)

        if not (cell_w and cell_h) then
            -- TIOCGWINSZ pixel fields unavailable; derive from character dimensions
            if cur_rows and cur_cols then
                local contentH = getContentHeight(context)
                local chrome_h = contentH and (frame.h - contentH) or 0
                cell_w = frame.w / cur_cols
                cell_h = (frame.h - chrome_h) / cur_rows
                logger.d("Measured cell size:", cell_w, "x", cell_h)
            else
                logger.w("Could not determine terminal dimensions for rows/cols resize")
            end
        end

        if cell_w and cell_h then
            local contentH = getContentHeight(context)
            local chrome_h = contentH and (frame.h - contentH) or 0
            if config.cols then
                frame.w = math.ceil(config.cols * cell_w)
            end
            if config.rows then
                frame.h = math.ceil(config.rows * cell_h + chrome_h)
            end
        end
    else
        if self.width then
            frame.w = self.width
            logger.v("Using fixed width:", frame.w)
        elseif config and config.width then
            frame.w = config.width
            logger.v("Using config width:", frame.w)
        end

        if self.height then
            frame.h = self.height
            logger.v("Using fixed height:", frame.h)
        elseif config and config.height then
            frame.h = config.height
            logger.v("Using config height:", frame.h)
        end
    end

    return frame
end

--- FrameResizer.QVGA
--- Variable
--- Predefined resizer for QVGA resolution (320x240).
FrameResizer.QVGA = FrameResizer:new(320, 240)

--- FrameResizer.VGA
--- Variable
--- Predefined resizer for VGA resolution (640x480).
FrameResizer.VGA = FrameResizer:new(640, 480)

--- FrameResizer.SVGA
--- Variable
--- Predefined resizer for SVGA resolution (800x600).
FrameResizer.SVGA = FrameResizer:new(800, 600)

--- FrameResizer.XGA
--- Variable
--- Predefined resizer for XGA resolution (1024x768).
FrameResizer.XGA = FrameResizer:new(1024, 768)

--- FrameResizer.WXGA
--- Variable
--- Predefined resizer for WXGA resolution (1280x720).
FrameResizer.WXGA = FrameResizer:new(1280, 720)

--- FrameResizer.SXGA
--- Variable
--- Predefined resizer for SXGA resolution (1280x1024).
FrameResizer.SXGA = FrameResizer:new(1280, 1024)

--- FrameResizer.UXGA
--- Variable
--- Predefined resizer for UXGA resolution (1600x1200).
FrameResizer.UXGA = FrameResizer:new(1600, 1200)

--- FrameResizer.WUXGA
--- Variable
--- Predefined resizer for WUXGA resolution (1920x1200).
FrameResizer.WUXGA = FrameResizer:new(1920, 1200)

--- FrameResizer.QXGA
--- Variable
--- Predefined resizer for QXGA resolution (2048x1536).
FrameResizer.QXGA = FrameResizer:new(2048, 1536)

--- FrameResizer.WQHD
--- Variable
--- Predefined resizer for WQHD resolution (2560x1440).
FrameResizer.WQHD = FrameResizer:new(2560, 1440)

return FrameResizer
