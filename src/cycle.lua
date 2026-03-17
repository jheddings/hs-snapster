--- CycleOp
--- Class
--- A layout operation that cycles through a list of steps on repeated presses.
---
--- Each step is a table of layout operations (e.g., {scaler, anchor}). On each
--- press, the current window frame is compared against the result of trial-applying
--- each step. If a match is found, the next step is applied (wrapping around).
--- If no match is found (e.g., the window was manually moved), step 1 is applied.

CycleOp = LayoutManager.Operation:new()
CycleOp.__index = CycleOp

local TOLERANCE = 5

--- CycleOp:new(...)
--- Method
--- Creates a new CycleOp instance.
---
--- Parameters:
---  * ... - Two or more step tables, where each step is a list of LayoutOperations
---
--- Returns:
---  * A new CycleOp instance
function CycleOp:new(...)
    local instance = {
        steps = {...}
    }
    return setmetatable(instance, self)
end

--- CycleOp:_trialApply(step, frame, context)
--- Method
--- Trial-applies a step's operations to a copy of the frame.
---
--- Parameters:
---  * step - A table of LayoutOperations
---  * frame - The current window frame
---  * context - The window object
---
--- Returns:
---  * The resulting frame after applying all operations in the step
function CycleOp:_trialApply(step, frame, context)
    local trial = hs.geometry.rect(frame.x, frame.y, frame.w, frame.h)
    for _, op in ipairs(step) do
        trial = op:apply(trial, context)
    end
    return trial
end

--- CycleOp:_framesMatch(a, b)
--- Method
--- Compares two frames for approximate equality.
---
--- Parameters:
---  * a - First frame
---  * b - Second frame
---
--- Returns:
---  * true if all coordinates match within TOLERANCE pixels
function CycleOp:_framesMatch(a, b)
    return math.abs(a.x - b.x) <= TOLERANCE
       and math.abs(a.y - b.y) <= TOLERANCE
       and math.abs(a.w - b.w) <= TOLERANCE
       and math.abs(a.h - b.h) <= TOLERANCE
end

--- CycleOp:apply(frame, context)
--- Method
--- Applies the next step in the cycle to the given frame.
---
--- Parameters:
---  * frame - The current window frame
---  * context - The window object
---
--- Returns:
---  * The modified frame after applying the next cycle step
function CycleOp:apply(frame, context)
    local logger = spoon.Snapster.logger

    -- Find which step matches the current frame
    local matchIndex = nil
    for i, step in ipairs(self.steps) do
        local trial = self:_trialApply(step, frame, context)
        if self:_framesMatch(frame, trial) then
            matchIndex = i
            break
        end
    end

    -- Advance to next step, or reset to 1 if no match
    local nextIndex = matchIndex and (matchIndex % #self.steps) + 1 or 1

    logger.d("CycleOp: match=", matchIndex, " next=", nextIndex)

    -- Apply the next step
    local result = hs.geometry.rect(frame.x, frame.y, frame.w, frame.h)
    for _, op in ipairs(self.steps[nextIndex]) do
        result = op:apply(result, context)
    end

    return result
end

return CycleOp
