# Snapster

Snapster is a Hammerspoon spoon that helps arrange windows on macOS. It provides a flexible system for window management through hotkeys, allowing you to position, resize, and scale windows with customizable layouts.

## Features

- **Window Scaling**: Resize windows as a percentage of screen size
- **Window Positioning**: Snap windows to different screen positions (left, right, top, bottom, corners)
- **Fixed Resolutions**: Set windows to standard resolutions (VGA, XGA, WXGA, etc.)
- **Application-Specific Settings**: Configure size constraints for individual applications
- **Customizable Hotkeys**: Bind keyboard shortcuts to window operations

## Installation

1. Download the latest release from the project's release page
2. Unzip the archive
3. Double-click `Snapster.spoon`
4. Add the following to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("Snapster")
```

Alternatively, you can build from source.

## Basic Usage

```lua
-- Load the spoon
hs.loadSpoon("Snapster")
local snap = spoon.Snapster

-- Set your window defaults
snap.defaults = {
  maximumWidth = 2000,
}

-- Configure application-specific settings
snap.apps = {
  ["Google Chrome"] = {width = 1280, height = 900},
  ["Code"] = {minimumWidth = 1600},
}

-- Setup key binding for half screen layouts
snap:bind({{"ctrl", "alt", "cmd"}, "left"}, snap.scale.halfWidth, snap.layout.left)
snap:bind({{"ctrl", "alt", "cmd"}, "right"}, snap.scale.halfWidth, snap.layout.right)
snap:bind({{"ctrl", "alt", "cmd"}, "up"}, snap.scale.halfHeight, snap.layout.top)
snap:bind({{"ctrl", "alt", "cmd"}, "down"}, snap.scale.halfHeight, snap.layout.bottom)

-- Setup key binding for quarter screen layouts
snap:bind({{"ctrl", "alt", "cmd"}, "U"}, snap.scale.quarterScreen, snap.layout.topLeft)
snap:bind({{"ctrl", "alt", "cmd"}, "I"}, snap.scale.quarterScreen, snap.layout.topRight)
snap:bind({{"ctrl", "alt", "cmd"}, "J"}, snap.scale.quarterScreen, snap.layout.bottomLeft)
snap:bind({{"ctrl", "alt", "cmd"}, "K"}, snap.scale.quarterScreen, snap.layout.bottomRight)

-- Setup key binding for full screen layout
snap:bind({{"ctrl", "alt", "cmd"}, "F"}, snap.scale.fullScreen)

-- Resize windows based on preferred size in snap.apps
snap:bind({{"ctrl", "alt", "cmd"}, "Y"}, snap.resize.config)

-- Start the spoon
snap:start()
```

## Configuration

### Default Settings

```lua
spoon.Snapster.defaults = {
  width = nil,          -- Default window width (in pixels)
  height = nil,         -- Default window height (in pixels)
  maximumWidth = nil,   -- Maximum allowed window width
  maximumHeight = nil,  -- Maximum allowed window height
  minimumWidth = nil,   -- Minimum allowed window width
  minimumHeight = nil,  -- Minimum allowed window height
}
```

### Predefined Layouts

Snapster comes with several predefined layouts:

- `snapster.layout.left` - Left half of the screen
- `snapster.layout.right` - Right half of the screen
- `snapster.layout.top` - Top half of the screen
- `snapster.layout.bottom` - Bottom half of the screen
- `snapster.layout.topLeft` - Top-left quarter of the screen
- `snapster.layout.topRight` - Top-right quarter of the screen
- `snapster.layout.bottomLeft` - Bottom-left quarter of the screen
- `snapster.layout.bottomRight` - Bottom-right quarter of the screen
- `snapster.layout.fullScreen` - Full screen

### Predefined Scales

- `snapster.scale.halfWidth` - 50% of screen width, full height
- `snapster.scale.halfHeight` - Full width, 50% of screen height
- `snapster.scale.fullScreen` - 100% of screen width and height
- `snapster.scale.quarterScreen` - 50% of screen width and height

### Predefined Sizes

- `snapster.resize.xsmall` - QVGA resolution (320x240)
- `snapster.resize.small` - VGA resolution (640x480)
- `snapster.resize.medium` - XGA resolution (1024x768)
- `snapster.resize.large` - SXGA resolution (1280x1024)
- `snapster.resize.xlarge` - WUXGA resolution (1920x1200)
- `snapster.resize.config` - Configure according to preferred size

## API

### Methods

- `bind(mapping, ...)`: Bind a hotkey to window operations
- `unbind(mapping)`: Remove a hotkey binding
- `start()`: Enable all hotkeys
- `stop()`: Disable all hotkeys

### Variables

- `showAlert`: Show alert with window dimensions after resizing (default: true)
- `defaults`: Default window settings
- `apps`: Application-specific settings

## Building from Source

```sh
make build       # Build the spoon
make build-zip   # Create a distributable zip file
make clean       # Remove build artifacts
```
