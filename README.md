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
4. Add the following to your [`build/Snapster.spoon/init.lua`](build/Snapster.spoon/init.lua ):

```lua
hs.loadSpoon("Snapster")
```

Alternatively, you can build from source:

```sh
git clone <repository-url>
cd hs-snapster
make build
cp -r build/Snapster.spoon ~/.hammerspoon/Spoons/
```

## Basic Usage

```lua
-- Load the spoon
local snapster = hs.loadSpoon("Snapster")

-- Set up window layouts with hotkeys
snapster
  :bind({{"ctrl", "alt", "cmd"}}, "left"}, snapster.scale.halfWidth, snapster.layout.left)
  :bind({{"ctrl", "alt", "cmd"}}, "right"}, snapster.scale.halfWidth, snapster.layout.right)
  :bind({{"ctrl", "alt", "cmd"}}, "f"}, snapster.scale.fullScreen, snapster.layout.fullScreen)
  :bind({{"ctrl", "alt", "cmd"}}, "m"}, snapster.resize.medium)
  :bind({{"ctrl", "alt", "cmd"}}, "l"}, snapster.resize.large)
  :start()

-- Configure application-specific settings
snapster.apps = {
  ["Google Chrome"] = {width = 1280, height = 900},
  ["Code"] = {minimumWidth = 1600},
}
```

## Configuration

### Default Settings

```lua
snapster.defaults = {
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

## API

### Methods

- `bind(mapping, ...)`: Bind a hotkey to window operations
- `unbind(mapping)`: Remove a hotkey binding
- `start()`: Enable all hotkeys
- `stop()`: Disable all hotkeys
- `getEffectiveConfig(app)`: Get configuration for an application

### Variables

- `showAlert`: Show alert with window dimensions after resizing (default: true)
- `defaults`: Default window settings
- `apps`: Application-specific settings
- `scale`: Predefined scaling factors
- `layout`: Predefined window layouts
- `resize`: Predefined window sizes

## Building from Source

```sh
make build       # Build the spoon
make build-zip   # Create a distributable zip file
make clean       # Remove build artifacts
```

## License

MIT License - See source code for details.

## Author

Jason Heddings
