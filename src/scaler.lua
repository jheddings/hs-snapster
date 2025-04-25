--- === FrameScaler ===
--- Handles scaling of window frames.

FrameScaler = LayoutManager.Operation:new()
FrameScaler.__index = FrameScaler

--- FrameScaler:new(width, height)
--- Method
--- Creates a new FrameScaler instance.
---
--- Parameters:
---  * width: The width as a fraction of the screen width (0 to 1)
---  * height: The height as a fraction of the screen height (0 to 1)
---
--- Returns:
---  * A new FrameScaler instance
function FrameScaler:new(width, height)
    local instance = {
        width = width,
        height = height
    }
    return setmetatable(instance, self)
end

--- FrameScaler:apply(frame, context)
--- Method
--- Applies the scaling to the specified window frame.
---
--- Parameters:
---  * frame: The window frame to be scaled
---  * context: The context object containing screen and application information
---
--- Returns:
---  * The modified frame with updated width and height
function FrameScaler:apply(frame, context)
    local screen = context:screen()
    local max = screen:frame()
    local app = context:application()

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
--- Predefined scaler for 1/2 screen width, full height.
FrameScaler.HALF_WIDTH = FrameScaler:new(0.5, 1)

--- FrameScaler.THIRD_WIDTH
--- Variable
--- Predefined scaler for 1/3 screen width, full height.
FrameScaler.THIRD_WIDTH = FrameScaler:new(0.333, 1)

--- FrameScaler.QUARTER_WIDTH
--- Variable
--- Predefined scaler for 1/4 screen width, full height.
FrameScaler.QUARTER_WIDTH = FrameScaler:new(0.25, 1)

--- FrameScaler.HALF_HEIGHT
--- Variable
--- Predefined scaler for 1/2 screen height, full width.
FrameScaler.HALF_HEIGHT = FrameScaler:new(1, 0.5)

--- FrameScaler.FULL_SCREEN
--- Variable
--- Predefined scaler for the full screen.
FrameScaler.FULL_SCREEN = FrameScaler:new(1, 1)

--- FrameScaler.QUARTER_SCREEN
--- Variable
--- Predefined scaler for 1/2 screen width and height (1/4 of the full screen).
FrameScaler.QUARTER_SCREEN = FrameScaler:new(0.5, 0.5)

return FrameScaler
