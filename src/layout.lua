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

--- LayoutManager:new(...)
--- Method
--- Creates a new LayoutManager instance.
---
--- Parameters:
---  * ... - Zero or more layout operation objects, each must implement an apply(win) method
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
---  * The window frame is only set once after all operations are complete
function LayoutManager:apply(win)
    local frame = win:frame()
    local app = win:application()
    local appname = app and app:name() or win:title()

    local logger = spoon.Snapster.logger

    logger.d("Begin layout:", appname, "[", win:title(), "]")
    logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    for _, layout in ipairs(self.operations) do
        frame = layout:apply(win)
        win:setFrame(frame)
    end

    logger.d("Layout complete:", appname, "[", win:title(), "]")
    logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    return frame
end

return LayoutManager
