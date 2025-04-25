--- === WindowHistory ===
--- Manage history of window frame changes

WindowHistory = {}
WindowHistory.__index = WindowHistory

--- WindowHistory:new(maxSize)
--- Method
--- Creates a new WindowHistory instance.
---
--- Parameters:
---  * maxSize - The maximum size of the history stack (defaults to 10).
---
--- Returns:
---  * A new WindowHistory instance
function WindowHistory:new(maxSize)
    local instance = {
        history = {},
        maxSize = maxSize or 10,
        index = 0,
        logger = hs.logger.new("WindowHistory", "info")
    }
    return setmetatable(instance, WindowHistory)
end

--- WindowHistory:push(win)
--- Method
--- Records the current state of a window to the history stack.
---
--- Parameters:
---  * win - An hs.window object to record the state of
---
--- Returns:
---  * The WindowHistory object for method chaining
---
--- Notes:
---  * If adding this entry exceeds the maximum history size, the oldest entry will be removed
function WindowHistory:push(win)
    if not win then
        self.logger.e("Window cannot be nil")
        return
    end

    local hist = { 
        id = win:id(), 
        frame = win:frame():copy(),
        app = win:application():name(),
        title = win:title()
    }

    self.logger.d(
        "Recording window history:", win:id(),
        "@ [", hist.frame.x, ",", hist.frame.y, "]",
        ":: (", hist.frame.w, "x", hist.frame.h, ")"
    )

    table.insert(self.history, hist)

    if #self.history > self.maxSize then
        table.remove(self.history, 1)
    end

    self.index = #self.history

    self.logger.v("Recorded window state:", win:id(), "@", self.index)

    return self
end

--- WindowHistory:pop()
--- Method
--- Restores a window to its previous state from the history stack.
---
--- Returns:
---  * The WindowHistory object for method chaining
---
--- Notes:
---  * Displays an alert if there's no more history to restore
---  * Handles cases where the original window no longer exists
function WindowHistory:pop()
    if self.index < 1 then
        hs.alert.show("End of window history")
        return nil
    end

    local hist = self.history[self.index]
    local win = hs.window.find(hist.id)

    if win then
        self.logger.d("Reverting window state [", hist.id, "] ::", self.index)
        win:setFrame(hist.frame)
    else
        self.logger.w("Window no longer exists [", hist.id, "]")
    end

    self.index = self.index - 1

    return self
end

--- WindowHistory:clear()
--- Method
--- Resets the window history, removing all stored states.
---
--- Returns:
---  * The WindowHistory object for method chaining
function WindowHistory:clear()
    self.history = {}
    self.index = 0

    self.logger.d("Cleared window history")

    return self
end

return WindowHistory
