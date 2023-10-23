-- colorChangeModule.lua

local M = {}

function M.changeColorOnMouse(object, mouseX, mouseY)
    local bounds = object.contentBounds

    if mouseX >= bounds.xMin and mouseX <= bounds.xMax and
       mouseY >= bounds.yMin and mouseY <= bounds.yMax then
        object:setFillColor(1, 0, 0)  -- Change object color to red (RGB: 1, 0, 0)
    else
        object:setFillColor(1, 1, 1)  -- Reset object color to white (RGB: 1, 1, 1)
    end
end

return M

---------------------------------------------------------------------------------------
-- main

-- local colorChangeModule = require("colorChangeModule")


-- local mouseX, mouseY = 1, 1
-- ---------------------------------------

-- -- Create a rectangle (display object)
-- local myRect = display.newRect(display.contentCenterX, display.contentCenterY, 100, 100)
-- myRect:setFillColor(1, 1, 1)  -- Set initial color to white

-- local function mousePosition(event)
--     mouseX, mouseY = event.x, event.y
-- end

-- local
-- -- Define the enterFrame event listener
-- local function onEnterFrame()
--     colorChangeModule.changeColorOnMouse(myRect, mouseX, mouseY)
-- end

-- -- Assign the enterFrame event listener
-- Runtime:addEventListener("enterFrame", onEnterFrame)
-- Runtime:addEventListener("mouse", mousePosition)
