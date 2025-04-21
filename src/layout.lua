--- FrameLayout
--- Class
--- Represents a layout for a window frame.

FrameLayout = {}
FrameLayout.__index = FrameLayout

local ANCHOR_LEFT = "left"
local ANCHOR_RIGHT = "right"
local ANCHOR_TOP = "top"
local ANCHOR_BOTTOM = "bottom"

--- FrameLayout:new(...)
--- Method
--- Creates a new FrameLayout instance with the specified anchors.
function FrameLayout:new(...)
    local instance = {
        anchors = {...}
    }
    return setmetatable(instance, self)
end

--- FrameLayout:apply(win)
--- Method
--- Applies the layout to the specified window.
function FrameLayout:apply(win)
    local frame = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local logger = spoon.Snapster.logger

    logger.d("FrameLayout:apply(", table.concat(self.anchors, ", "), ")")

    if hs.fnutils.contains(self.anchors, ANCHOR_LEFT) then
        frame.x = max.x
        logger.d("Left anchor:", frame.x)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_RIGHT) then
        frame.x = max.x + max.w - frame.w
        logger.d("Right anchor:", frame.x)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_TOP) then
        frame.y = max.y
        logger.d("Top anchor:", frame.y)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_BOTTOM) then
        frame.y = max.y + max.h - frame.h
        logger.d("Bottom anchor:", frame.y)
    end

    return frame
end

--- FrameLayout.LEFT
--- Variable
--- Predefined layout for the left half of the screen.
FrameLayout.LEFT_HALF = FrameLayout:new(ANCHOR_LEFT, ANCHOR_TOP, ANCHOR_BOTTOM)

--- FrameLayout.RIGHT
--- Variable
--- Predefined layout for the right half of the screen.
FrameLayout.RIGHT_HALF = FrameLayout:new(ANCHOR_RIGHT, ANCHOR_TOP, ANCHOR_BOTTOM)

--- FrameLayout.TOP_HALF
--- Variable
--- Predefined layout for the top half of the screen.
FrameLayout.TOP_HALF = FrameLayout:new(ANCHOR_TOP, ANCHOR_LEFT, ANCHOR_RIGHT)

--- FrameLayout.BOTTOM_HALF
--- Variable
--- Predefined layout for the bottom half of the screen.
FrameLayout.BOTTOM_HALF = FrameLayout:new(ANCHOR_BOTTOM, ANCHOR_LEFT, ANCHOR_RIGHT)

--- FrameLayout.TOP_LEFT
--- Variable
--- Predefined layout for the top left corner of the screen.
FrameLayout.TOP_LEFT = FrameLayout:new(ANCHOR_TOP, ANCHOR_LEFT)

--- FrameLayout.BOTTOM_LEFT
--- Variable
--- Predefined layout for the bottom left corner of the screen.
FrameLayout.BOTTOM_LEFT = FrameLayout:new(ANCHOR_BOTTOM, ANCHOR_LEFT)

--- FrameLayout.TOP_RIGHT
--- Variable
--- Predefined layout for the top right corner of the screen.
FrameLayout.TOP_RIGHT = FrameLayout:new(ANCHOR_TOP, ANCHOR_RIGHT)

--- FrameLayout.BOTTOM_RIGHT
--- Variable
--- Predefined layout for the bottom right corner of the screen.
FrameLayout.BOTTOM_RIGHT = FrameLayout:new(ANCHOR_BOTTOM, ANCHOR_RIGHT)

--- FrameLayout.FULL_SCREEN
--- Variable
--- Predefined layout for the full screen.
FrameLayout.FULL_SCREEN = FrameLayout:new(ANCHOR_LEFT, ANCHOR_RIGHT, ANCHOR_TOP, ANCHOR_BOTTOM)

return FrameLayout
