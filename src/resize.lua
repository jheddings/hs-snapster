--- FrameResizer
--- Class
--- Handles resizing of window frames based on a configuration.

FrameResizer = {}
FrameResizer.__index = FrameResizer

--- FrameResizer:new(...)
--- Method
--- Creates a new FrameResizer instance.
function FrameResizer:new(width, height)
    local instance = {
        width = width or nil,
        height = height or nil,
    }
    return setmetatable(instance, self)
end

--- FrameResizer:apply(win)
--- Method
--- Applies the resizing to the specified window.
---
--- Remarks:
---  * The resizing is based on the effective configuration of the application.
function FrameResizer:apply(win)
    local frame = win:frame()
    local app = win:application()

    local logger = spoon.Snapster.logger
    local config = spoon.Snapster:getEffectiveConfig(app)

    logger.d("FrameResizer:apply(", self.width, ", ", self.height, ")")

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
