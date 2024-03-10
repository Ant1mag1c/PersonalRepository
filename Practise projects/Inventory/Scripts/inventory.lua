local M = {}

local onCloseCallback -- Declare callback variable
local bodyGroup -- Declare displayGroup where all objects will be included

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
    onCloseCallback = callback -- Store the callback function

    print("Window Created")
    bodyGroup = display.newGroup()

    local body = display.newRect(parent, x, y, width, height)
    body:setFillColor(0.2)

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
