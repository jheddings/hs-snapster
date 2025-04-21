--- === Snapster ===
---
--- Snapster is a Hammerspoon spoon that helps arrange windows on macOS.

local FrameScaler = dofile(hs.spoons.resourcePath("scaler.lua"))
local FrameLayout = dofile(hs.spoons.resourcePath("layout.lua"))
local FrameResizer = dofile(hs.spoons.resourcePath("resize.lua"))

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Snapster"
obj.version = "1.0"
obj.author = "Jason Heddings"
obj.license = "MIT"

-- Internal Properties
obj.logger = hs.logger.new("Snapster", "info")
obj.hotkeys = {}

-- Configuration

--- Snapster.showAlert
--- Variable
--- A boolean that determines whether to show an alert when a window is resized.
obj.showAlert = true

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

--- Snapster.layout
--- Variable
--- A table of predefined window layouts.
obj.layout = {
    left = FrameLayout.LEFT_HALF,
    right = FrameLayout.RIGHT_HALF,
    top = FrameLayout.TOP_HALF,
    bottom = FrameLayout.BOTTOM_HALF,
    topLeft = FrameLayout.TOP_LEFT,
    bottomLeft = FrameLayout.BOTTOM_LEFT,
    topRight = FrameLayout.TOP_RIGHT,
    bottomRight = FrameLayout.BOTTOM_RIGHT,
    fullScreen = FrameLayout.FULL_SCREEN
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

    local keyname = table.concat(mods, "-")
    return keyname:lower() .. "-" .. key:upper()
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
    local appname = app:name()
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
function obj:_apply(layouts)
    local win = hs.window.focusedWindow()

    if not win then
        self.logger.w("No focused window")
        return
    end

    local frame = win:frame()
    local app = win:application()
    local appname = app and app:name() or win:title()

    self.logger.d("Begin layout:", appname, "[", win:title(), "]")
    self.logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    for _, layout in ipairs(layouts) do
        frame = layout:apply(win)
        win:setFrame(frame)
    end

    self.logger.i(
        "Moving", appname,
        "to (", frame.w, "x", frame.h,
        ") @ [", frame.x, ",", frame.y, "]"
    ) 

    if self.showAlert then
        hs.alert.show(appname .. " (" .. frame.w .. "x" .. frame.h .. ")")
    end

    self.logger.d("Layout complete:", appname, "[", win:title(), "]")
    self.logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")
end

--- Snapster:bind(mapping, width, height, anchors)
--- Method
--- Binds a hotkey to the given layout.
---
--- Parameters:
---  * mapping - A table {mods, key} defining the hotkey
---  * ... - A list of layout operations to apply
---
--- Remarks:
---  * The layout operations will be applied in the order they are provided.
function obj:bind(mapping, ...)
    local mods = mapping[1]
    local key = mapping[2]
    local keyname = keyname(mods, key)

    local layouts = {...}

    -- Clean up existing hotkey if it exists
    if self.hotkeys[keyname] then
        self.logger.w("Hotkey", keyname, "exists. Replacing.")
        self.hotkeys[keyname]:delete()
    end

    self.logger.d("Binding hotkey", keyname)

    -- Create the new hotkey
    self.hotkeys[keyname] = hs.hotkey.new(mods, key, function() self:_apply(layouts) end)
    
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
    local keyname = keyname(mods, key)
    
    if self.hotkeys[keyname] then
        self.hotkeys[keyname]:delete()
        self.hotkeys[keyname] = nil
        self.logger.d("Unbinding hotkey", keyname)
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
    for _, hotkey in pairs(self.hotkeys) do
        hotkey:disable()
    end
    
    self.logger.i("Snapster stopped")

    return self
end

return obj
