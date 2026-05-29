local widget = require("widget")
local screen = require("classes.screen")
local funcs = require("libs.globalFuncs")
local cx, cy = screen.centerX, screen.centerY
local maxX, maxY, minX, minY = screen.maxX, screen.maxY, screen.minX, screen.minY

-- State
local isActive = false

-- Functions
local newFrame

local debug = {}

-- Temporary instant run
local function runDebug()
    local startItems = {
        sword = true,
        
        log = true,
    }


    if next(startItems) then
        local p = require("data.stateHandler").get().player
        for k, v in pairs(startItems) do
            p:handleItem(k, 5)
        end
    end
end

function debug:newButton(parent)
    local groupFrame = display.newGroup()
    parent:insert(groupFrame)

    local funcs = require("libs.globalFuncs")
    local button
    button = funcs:newButton( {
            parent = parent,
            x = screen.maxX-22,
            y = screen.minY+8,
            width = 40,
            height = 12,
            id = "debug",
            label = "DEBUG",
            fontSize = 11,
            callback = function () newFrame(parent, groupFrame, button) end,
            -- isSwitch = true,
    } )

    -- For now just create autoRun debug 
    runDebug()
    
    return button
end

----------------------------------------------------------------------------------------------------

function newFrame(parent, groupFrame, button)
    if isActive then
        for i = groupFrame.numChildren, 1, -1 do
            display.remove(groupFrame[i])
            groupFrame[i] = nil
        end

        isActive = false
        return
    end
    isActive = true

    local dimmer = require("libs.effects"):getDimmer(true)
    groupFrame:insert(dimmer)

    local bg = display.newRect( groupFrame, screen.centerX, screen.centerY, screen.width-100, screen.height-50 )
    bg:setFillColor(unpack({ 0.83, 0.77, 0.63 }))

    button:toFront()

    -- Generate add/remove buttons for items
    local assets = require("data.assets")

    local count = 1
    for k,v in pairs(assets) do
        if v.type == "utility" or v.type == "material" then 
            -- Create button 
            -- local buttonAdd = require("libs.globalFuncs"):newButton( {
            local f = require("libs.globalFuncs")
            local labelBG = display.newRect( groupFrame, cx - 140, cy - 110, 30, 20 ) 
            local buttonRemove = f:newButton( {
                parent = groupFrame,
                x = cx + 70,
                y = cy + (25 * count),
                label = "-",
                fontSize = 10,
                width = 20,
                height = 18,
                callback = function ()
                    local p = require("data.stateHandler").get().player
                    p:handleItem(k, -5 )
                end
            } )

            local buttonAdd = f:newButton( {
                parent = groupFrame,
                x = cx,
                y = cy + (25 * count),
                label = "+",
                fontSize = 10,
                width = 20,
                height = 18,
                callback = function ()
                    local p = require("data.stateHandler").get().player
                    p:handleItem(k, 5 )
                end
            } )

            count = count + 1
        end 
    end


end







return debug