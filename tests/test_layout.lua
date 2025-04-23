-- Unit tests for the ScreenAnchor module

local lu = require("luaunit")

local LayoutManager = require("src.layout")
local ScreenAnchor = require("src.anchor")

-- Mock required dependencies
_G.hs = {
    fnutils = {
        contains = function(table, value)
            for _, v in ipairs(table) do
                if v == value then
                    return true
                end
            end
            return false
        end
    }
}

_G.spoon = {
    Snapster = {
        logger = {
            v = function(...) end,
            d = function(...) end,
            i = function(...) end
        }
    }
}

-- Test cases for ScreenAnchor
TestFrameLayout = {}

function TestFrameLayout:setUp()
    self.testFrame = {x = 100, y = 100, w = 400, h = 300}
    self.screenFrame = {x = 0, y = 0, w = 1000, h = 1000}
    
    self.mockWindow = {
        frame = function() 
            return self.testFrame
        end,
        screen = function() 
            return {
                frame = function()
                    return self.screenFrame
                end
            }
        end
    }
end

function TestFrameLayout:testLeftAnchor()
    local layout = ScreenAnchor:new("left")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 0)      -- Left edge of screen
    lu.assertEquals(frame.y, 100)    -- Y position unchanged
end

function TestFrameLayout:testRightAnchor()
    local layout = ScreenAnchor:new("right")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 600)    -- Right edge (1000 - 400)
    lu.assertEquals(frame.y, 100)    -- Y position unchanged
end

function TestFrameLayout:testTopAnchor()
    local layout = ScreenAnchor:new("top")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 100)    -- X position unchanged
    lu.assertEquals(frame.y, 0)      -- Top edge of screen
end

function TestFrameLayout:testBottomAnchor()
    local layout = ScreenAnchor:new("bottom")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 100)    -- X position unchanged
    lu.assertEquals(frame.y, 700)    -- Bottom edge (1000 - 300)
end

function TestFrameLayout:testTopLeftCorner()
    local layout = ScreenAnchor:new("left", "top")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 0)     -- Left edge of screen
    lu.assertEquals(frame.y, 0)     -- Top edge of screen
end

function TestFrameLayout:testBottomRightCorner()
    local layout = ScreenAnchor:new("right", "bottom")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 600)    -- Right edge (1000 - 400)
    lu.assertEquals(frame.y, 700)    -- Bottom edge (1000 - 300)
end

function TestFrameLayout:testCustomScreenSize()
    self.screenFrame = {x = 50, y = 75, w = 800, h = 600}
    
    local layout = ScreenAnchor:new("right", "bottom")
    local frame = layout:apply(self.testFrame, self.mockWindow)

    lu.assertEquals(frame.x, 450)    -- Right edge (50 + 800 - 400)
    lu.assertEquals(frame.y, 375)    -- Bottom edge (75 + 600 - 300)
end

-- Run the tests
os.exit(lu.LuaUnit.run())
