--- LayoutManager
--- Class
--- Manages and applies multiple window layout operations in sequence.
---
--- The LayoutManager coordinates multiple layout operations (like resizing, 
--- positioning, or anchoring) to be applied to a window in the proper order.
--- Each operation must implement an `apply(win)` method that takes a window
--- and returns a modified frame.

LayoutManager = {}
LayoutManager.__index = LayoutManager

--- LayoutOperation
--- Class
--- Base class for window layout operations.
---
--- Layout operations perform specific window manipulations like resizing,
--- positioning, or anchoring. Each operation should be designed to perform
--- a single transform on a window frame.

LayoutOperation = {}
LayoutOperation.__index = LayoutOperation

--- LayoutOperation:new(obj)
--- Method
--- Creates a new LayoutOperation instance.
---
--- Parameters:
---  * obj - An optional table with properties to be merged into the new instance
---
--- Returns:
---  * A new LayoutOperation instance
function LayoutOperation:new(obj)
    local instance = obj or {}
    setmetatable(instance, self)
    return instance
end

--- LayoutOperation:apply(frame, context)
--- Method
--- Applies a layout transformation to the given frame.
---
--- Parameters:
---  * frame - An hs.geometry rect representing the current window frame
---  * context - The window object providing context for the layout operation
---
--- Returns:
---  * A modified frame (hs.geometry rect) after applying the layout operation
function LayoutOperation:apply(frame, context)
    error("apply() must be implemented by subclass")
end

--- LayoutManager:new(...)
--- Method
--- Creates a new LayoutManager instance.
---
--- Parameters:
---  * ... - Zero or more layout operation objects, each must implement an apply(frame, context) method
---
--- Returns:
---  * A new LayoutManager instance
function LayoutManager:new(...)
    local instance = {
        operations = {...}
    }
    return setmetatable(instance, self)
end

--- LayoutManager:apply(win)
--- Method
--- Applies the layout operations to the specified window.
---
--- Parameters:
---  * win - An hs.window object to apply the layout operations to
---
--- Returns:
---  * The final frame after all operations have been applied
---
--- Notes:
---  * Each layout operation is called in sequence
function LayoutManager:apply(win)
    local frame = win:frame()
    local app = win:application()
    local appname = app and app:name() or win:title()

    local logger = spoon.Snapster.logger

    logger.d("Begin layout:", appname, "[", win:title(), "]")
    logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    for _, op in ipairs(self.operations) do
        frame = op:apply(frame, win)
    end

    logger.i("Moving", appname, "to (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]") 

    win:setFrame(frame)

    logger.d("Layout complete:", appname, "[", win:title(), "]")
    logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    return frame
end

return LayoutManager
