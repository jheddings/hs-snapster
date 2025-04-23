--- === Snapster ===
---
--- Snapster is a Hammerspoon spoon that helps arrange windows on macOS.

local LayoutManager = dofile(hs.spoons.resourcePath("layout.lua"))
local FrameScaler = dofile(hs.spoons.resourcePath("scaler.lua"))
local ScreenAnchor = dofile(hs.spoons.resourcePath("anchor.lua"))
local FrameResizer = dofile(hs.spoons.resourcePath("resize.lua"))
local WindowHistory = dofile(hs.spoons.resourcePath("undo.lua"))

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Snapster"
obj.version = "1.3"
obj.author = "Jason Heddings"
obj.license = "MIT"

-- Internal Properties
obj.logger = hs.logger.new("Snapster", "info")
obj.hotkeys = {}
obj.history = nil

-- Configuration

--- Snapster.showAlert
--- Variable
--- A boolean that determines whether to show an alert when a window is resized.
---
--- Notes:
---  * The default is `true`
obj.showAlert = true

--- Snapster.maxHistorySize
--- Variable
--- The maximum number of window states to keep in history.
---
--- Notes:
---  * The default is 10
---  * Set to 0 to disable history
obj.maxHistorySize = 10

--- Snapster.defaults
--- Variable
--- A table of default window settings for the Snapster spoon.
obj.defaults = {
    width = nil,
    height = nil,

    maximumWidth = nil,
    maximumHeight = nil,

    minimumWidth = nil,
    minimumHeight = nil,
}

--- Snapster.apps
--- Variable
--- Override the default window settings for specific applications.
---
--- The table consists of application names as keys and a table of settings as values.
--- Settings may include any option from the defaults table.  Only settings that are
--- specified will override the defaults.
---
--- Example:
---   snapster.apps = {
---     ["Google Chrome"] = {width = 1280, height = 900},
---     ["Code"] = {minimumWidth = 1600},
---   }
obj.apps = {}

--- Snapster.scale
--- Variable
--- A table of predefined scaling factors.
obj.scale = {
    halfWidth = FrameScaler.HALF_WIDTH,
    halfHeight = FrameScaler.HALF_HEIGHT,
    fullScreen = FrameScaler.FULL_SCREEN,
    quarterScreen = FrameScaler.QUARTER_SCREEN,
}

--- Snapster.anchor
--- Variable
--- A table of predefined screen anchors.
obj.anchor = {
    left = ScreenAnchor.LEFT_SIDE,
    right = ScreenAnchor.RIGHT_SIDE,
    top = ScreenAnchor.TOP_OF_SCREEN,
    bottom = ScreenAnchor.BOTTOM_OF_SCREEN,
    topLeft = ScreenAnchor.TOP_LEFT,
    bottomLeft = ScreenAnchor.BOTTOM_LEFT,
    topRight = ScreenAnchor.TOP_RIGHT,
    bottomRight = ScreenAnchor.BOTTOM_RIGHT,
    fullScreen = ScreenAnchor.FULL_SCREEN
}

--- Snapster.resize
--- Variable
--- A table of predefined window sizes.
obj.resize = {
    config = FrameResizer:new(),
    xsmall = FrameResizer.QVGA,
    small = FrameResizer.VGA,
    medium = FrameResizer.XGA,
    large = FrameResizer.SXGA,
    xlarge = FrameResizer.WUXGA
}

--- keyname(mods, key)
--- Function
--- Builds a consistent string representation of a hotkey combination.
---
--- Parameters:
---  * mods - An array of modifier keys (e.g., {"cmd", "alt"})
---  * key - A string representing the key (e.g., "s" or "return")
---
--- Returns:
---  * A standardized string representation of the hotkey (e.g., "alt-cmd-S")
---
--- Notes:
---  * Modifier keys are sorted and converted to lowercase
---  * The key is converted to uppercase
---  * This is used internally to create consistent keys for the hotkeys table
local function keyname(mods, key)
    -- Sort the modifiers for consistent naming
    table.sort(mods)

    local name = table.concat(mods, "-")
    return name:lower() .. "-" .. key:upper()
end

--- Snapster:getEffectiveConfig(app)
--- Method
--- Returns the effective configuration for an application by combining default settings with app-specific overrides.
---
--- Parameters:
---  * app - An hs.application object representing the application
---
--- Returns:
---  * A table containing the effective configuration settings for the application
function obj:getEffectiveConfig(app)
    local appname = app and app:name() or nil
    local config = {}
    
    -- Start with defaults
    for k, v in pairs(self.defaults) do
        config[k] = v
    end
    
    -- Override with app-specific settings if they exist
    if appname and self.apps[appname] then
        for k, v in pairs(self.apps[appname]) do
            config[k] = v
        end
    end
    
    return config
end

--- Snapster:_apply(layouts)
--- Method
--- Internal method that applies a list of layouts to the currently focused window.
---
--- Parameters:
---  * layouts - A table of layout objects to apply in sequence
---
--- Notes:
---  * Each layout object in the list must have an apply() method that takes a window object
---  * If showAlert is true, displays an alert with the window dimensions after applying layouts
function obj:_apply(layout)
    local win = hs.window.focusedWindow()

    if not win then
        self.logger.w("Cannot determine current window")
        return
    end
    
    local app = win:application()
    local appname = app and app:name() or win:title()

    self.history:push(win)

    local frame = layout:apply(win)

    if self.showAlert then
        hs.alert.show(appname .. " (" .. frame.w .. "x" .. frame.h .. ")")
    end
end

--- Snapster:bind(mapping, width, height, anchors)
--- Method
--- Binds a hotkey to the given layout.
---
--- Parameters:
---  * mapping - A table {mods, key} defining the hotkey
---  * ... - A list of layout operations to apply
---
--- Notes:
---  * The layout operations will be applied in the order they are provided.
function obj:bind(mapping, ...)
    local mods = mapping[1]
    local key = mapping[2]
    local keyBinding = keyname(mods, key)

    local mgr = LayoutManager:new(...)

    -- Clean up existing hotkey if it exists
    if self.hotkeys[keyBinding] then
        self.logger.w("Hotkey", keyBinding, "exists. Replacing.")
        self.hotkeys[keyBinding]:delete()
    end

    self.logger.d("Binding hotkey", keyBinding)

    -- Create the new hotkey
    self.hotkeys[keyBinding] = hs.hotkey.new(
        mods, key, function() self:_apply(mgr) end
    )
    
    return self
end

--- Snapster:unbind(mapping)
--- Method
--- Unbinds a hotkey.
---
--- Parameters:
---  * mapping - A table {mods, key} defining the hotkey
---
--- Returns:
---  * The Snapster object
function obj:unbind(mapping)
    local mods = mapping[1]
    local key = mapping[2]
    local keyBinding = keyname(mods, key)
    
    if self.hotkeys[keyBinding] then
        self.hotkeys[keyBinding]:delete()
        self.hotkeys[keyBinding] = nil
        self.logger.d("Unbinding hotkey", keyBinding)
    end
    
    return self
end

--- Snapster:start()
--- Method
--- Start Snapster
---
--- Returns:
---  * The Snapster object
function obj:start()
    self.logger.d("Starting Snapster")

    if self.maxHistorySize > 0 then
        self.history = WindowHistory:new(self.maxHistorySize)
    end

    for _, hotkey in pairs(self.hotkeys) do
        hotkey:enable()
    end
    
    self.logger.i("Snapster started")

    return self
end

--- Snapster:stop()
--- Method
--- Stops Snapster
---
--- Returns:
---  * The Snapster object
function obj:stop()
    self.logger.d("Stopping Snapster")

    for _, hotkey in pairs(self.hotkeys) do
        hotkey:disable()
    end
    
    if self.history then
        self.history:clear()
        self.history = nil
    end

    self.logger.i("Snapster stopped")

    return self
end

--- Snapster:undo()
--- Method
--- Undoes the last window operation, restoring the previous window state.
---
--- Returns:
---  * The Snapster object
function obj:undo()
    self.history:pop()
    return self
end

return obj
