--- ScreenAnchor
--- Class
--- Methods for anchoring windows to screen locations.

ScreenAnchor = {}
ScreenAnchor.__index = ScreenAnchor

local ANCHOR_LEFT = "left"
local ANCHOR_RIGHT = "right"
local ANCHOR_TOP = "top"
local ANCHOR_BOTTOM = "bottom"

--- ScreenAnchor:new(...)
--- Method
--- Creates a new ScreenAnchor instance with the specified anchors.
function ScreenAnchor:new(...)
    local instance = {
        anchors = {...}
    }
    return setmetatable(instance, self)
end

--- ScreenAnchor:apply(win)
--- Method
--- Applies the anchors to the specified window.
function ScreenAnchor:apply(win)
    local frame = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local logger = spoon.Snapster.logger

    logger.d("ScreenAnchor:apply(", table.concat(self.anchors, ", "), ")")

    if hs.fnutils.contains(self.anchors, ANCHOR_LEFT) then
        frame.x = max.x
        logger.v("Left anchor:", frame.x)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_RIGHT) then
        frame.x = max.x + max.w - frame.w
        logger.v("Right anchor:", frame.x)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_TOP) then
        frame.y = max.y
        logger.v("Top anchor:", frame.y)
    end

    if hs.fnutils.contains(self.anchors, ANCHOR_BOTTOM) then
        frame.y = max.y + max.h - frame.h
        logger.v("Bottom anchor:", frame.y)
    end

    return frame
end

--- ScreenAnchor.LEFT_SIDE
--- Variable
--- Predefined anchors for the left side of the screen.
ScreenAnchor.LEFT_SIDE = ScreenAnchor:new(ANCHOR_LEFT, ANCHOR_TOP, ANCHOR_BOTTOM)

--- ScreenAnchor.RIGHT_SIDE
--- Variable
--- Predefined anchors for the right side of the screen.
ScreenAnchor.RIGHT_SIDE = ScreenAnchor:new(ANCHOR_RIGHT, ANCHOR_TOP, ANCHOR_BOTTOM)

--- ScreenAnchor.TOP_OF_SCREEN
--- Variable
--- Predefined anchors for the top of the screen.
ScreenAnchor.TOP_OF_SCREEN = ScreenAnchor:new(ANCHOR_TOP, ANCHOR_LEFT, ANCHOR_RIGHT)

--- ScreenAnchor.BOTTOM_OF_SCREEN
--- Variable
--- Predefined anchors for the bottom of the screen.
ScreenAnchor.BOTTOM_OF_SCREEN = ScreenAnchor:new(ANCHOR_BOTTOM, ANCHOR_LEFT, ANCHOR_RIGHT)

--- ScreenAnchor.TOP_LEFT
--- Variable
--- Predefined anchors for the top left corner of the screen.
ScreenAnchor.TOP_LEFT = ScreenAnchor:new(ANCHOR_TOP, ANCHOR_LEFT)

--- ScreenAnchor.BOTTOM_LEFT
--- Variable
--- Predefined anchors for the bottom left corner of the screen.
ScreenAnchor.BOTTOM_LEFT = ScreenAnchor:new(ANCHOR_BOTTOM, ANCHOR_LEFT)

--- ScreenAnchor.TOP_RIGHT
--- Variable
--- Predefined anchors for the top right corner of the screen.
ScreenAnchor.TOP_RIGHT = ScreenAnchor:new(ANCHOR_TOP, ANCHOR_RIGHT)

--- ScreenAnchor.BOTTOM_RIGHT
--- Variable
--- Predefined anchors for the bottom right corner of the screen.
ScreenAnchor.BOTTOM_RIGHT = ScreenAnchor:new(ANCHOR_BOTTOM, ANCHOR_RIGHT)

--- ScreenAnchor.FULL_SCREEN
--- Variable
--- Predefined anchors for the full screen.
ScreenAnchor.FULL_SCREEN = ScreenAnchor:new(ANCHOR_LEFT, ANCHOR_RIGHT, ANCHOR_TOP, ANCHOR_BOTTOM)

return ScreenAnchor
