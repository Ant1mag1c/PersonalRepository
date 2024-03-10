local itemData = require("Data.itemData")
local M = {}

local onCloseCallback -- Declare callback variable
local bodyGroup -- Declare displayGroup where all objects will be included
local ownedItem = {}
local item = {}


local function handleTouch(event)
    local phase = event.phase
    local target = event.target

    if phase == "ended" then
        if target.id == "close" then
            display.remove(bodyGroup)
            bodyGroup = nil

            -- Call the callback function to inform the main script
            if onCloseCallback then
                onCloseCallback()
            end
        end
    end
end

function M.show(parent, x, y, width, height, callback)
    print("Window Created")
    onCloseCallback = callback -- Store the callback function

    -- Import all owned items into ownedItem table
    for i = 1, #itemData do
        if itemData[i].isOwned then
            ownedItem[i] = itemData[i]
        end
    end

    bodyGroup = display.newGroup()

    local body = display.newRect(parent, x, y, width, height)
    body:setFillColor(0.2)

    for i = 1, #ownedItem do
        print("Item imported")
        local slot = display.newImageRect( bodyGroup, ownedItem[i].image, 100, 100, 50, 50)
        slot.x, slot.y = 100, 100--(body.width*1.8), body.y - (body.height*0.4)
        slot:toFront()
        item[i] = slot
        return slot
    end

    -- Button to close window
    local closeButton = display.newRect(parent, body.x + (body.width*0.43), body.height - 20, 25, 30)
    closeButton:setFillColor(0.5)
    closeButton.id = "close"
    closeButton:addEventListener("touch", handleTouch)

    local cross = display.newText(parent, "X", closeButton.x, closeButton.y, native.systemFont, 37)
    cross:setFillColor(1, 0, 0)

    bodyGroup:insert(body)
    bodyGroup:insert(closeButton)
    bodyGroup:insert(cross)

    return bodyGroup
end

return M
