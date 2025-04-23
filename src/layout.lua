--- LayoutManager
--- Class
--- Intelligently applies multiple layout operations in the correct order

LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager:new(...)
    local instance = {
        operations = {...}
    }
    return setmetatable(instance, self)
end

--- LayoutManager:apply(win)
--- Method
--- Applies the layout operations to the specified window.
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

    logger.i("Moving", appname, "to (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]") 

    win:setFrame(frame)

    logger.d("Layout complete:", appname, "[", win:title(), "]")
    logger.d("  => (", frame.w, "x", frame.h, ") @ [", frame.x, ",", frame.y, "]")

    return frame
end

return LayoutManager
