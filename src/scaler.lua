--- FrameScaler
--- Class
--- Handles scaling of window frames.

FrameScaler = {}
FrameScaler.__index = FrameScaler

--- FrameScaler:new(...)
--- Method
--- Creates a new FrameScaler instance.
---
--- Parameters:
---  * width: The width as a fraction of the screen width (0 to 1).
---  * height: The height as a fraction of the screen height (0 to 1).
function FrameScaler:new(width, height)
    local instance = {
        width = width,
        height = height
    }
    return setmetatable(instance, self)
end

--- FrameScaler:apply(win)
--- Method
--- Applies the scaling to the specified window.
function FrameScaler:apply(win)
    local frame = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local app = win:application()

    local logger = spoon.Snapster.logger
    local config = spoon.Snapster:getEffectiveConfig(app)

    logger.d("FrameScaler:apply(", self.width, ", ", self.height, ")")

    frame.w = math.floor(max.w * self.width)
    frame.h = math.floor(max.h * self.height)

    if config and config.maximumWidth then
        frame.w = math.min(frame.w, config.maximumWidth)
        logger.v("Applying maximum width:", frame.w)
    end

    if config and config.maximumHeight then
        frame.h = math.min(frame.h, config.maximumHeight)
        logger.v("Applying maximum height:", frame.h)
    end

    if config and config.minimumWidth then
        frame.w = math.max(frame.w, config.minimumWidth)
        logger.v("Applying minimum width:", frame.w)
    end

    if config and config.minimumHeight then
        frame.h = math.max(frame.h, config.minimumHeight)
        logger.v("Applying minimum height:", frame.h)
    end

    return frame
end

--- FrameScaler.HALF_WIDTH
--- Variable
--- Predefined scaler for half the screen width.
FrameScaler.HALF_WIDTH = FrameScaler:new(0.5, 1)

--- FrameScaler.THIRD_WIDTH
--- Variable
--- Predefined scaler for one-third of the screen width.
FrameScaler.THIRD_WIDTH = FrameScaler:new(0.333, 1)

--- FrameScaler.QUARTER_WIDTH
--- Variable
--- Predefined scaler for one-quarter of the screen width.
FrameScaler.QUARTER_WIDTH = FrameScaler:new(0.25, 1)

--- FrameScaler.HALF_HEIGHT
--- Variable
--- Predefined scaler for half the screen height.
FrameScaler.HALF_HEIGHT = FrameScaler:new(1, 0.5)

--- FrameScaler.FULL_SCREEN
--- Variable
--- Predefined scaler for the full screen.
FrameScaler.FULL_SCREEN = FrameScaler:new(1, 1)

--- FrameScaler.QUARTER_SCREEN
--- Variable
--- Predefined scaler for one-quarter of the screen.
FrameScaler.QUARTER_SCREEN = FrameScaler:new(0.5, 0.5)

return FrameScaler
