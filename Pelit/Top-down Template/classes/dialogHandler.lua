local screen = require("classes.screen")
local M = {}

local group
local frame, textObject

local frameIsVisible = false
local textIsVisible = false

local messages = {}

local frameFadeTime = 500

local setMessageVisibility, setFrameVisibility, getNextMessage, createText

local textOptions = {
    parent = group,
    x = 0,
    y = 0,
    text = "",
    font = native.systemFontBold,
    fontSize = 14,
}

function createText()
    textObject = display.newText( textOptions )
    textObject.text = messages[1]
    textObject.x, textObject.y = frame.x-50, (frame.y-30) 
    textObject.alpha = 0

end

local fadeParams = {}

local function fadeObject( object, setVisible )
    -- transition.fadeIn
    -- transition.fadeOut
end


function getNextMessage()
    table.remove(messages, 1)

    if not messages[1] then
        setFrameVisibility( false)
        return
    end

    setMessageVisibility( true )
end


local function handleMessage( content )
    -- table.print( content )

    -- Single line
    if type(content[1]) == "string" then
        -- Filter out duplicate messagesd
        for i = #messages, 1, -1 do
            if messages[i] == content[1] then print("duplicate found") return false end
        end    
        
        messages[#messages + 1] = content[1]
    else
        for i = 1, #content do
            local nextMessage = content[i][1] 

            messages[#messages + 1] = nextMessage
        end
    end
    
    createText()
    
end

function M.newFrame( parent )
    group = display.newGroup()
    parent:insert( group )

    frame = display.newRect(group, screen.centerX, screen.maxY, 200, 45)
    frame.anchorY = 1
    frame:setFillColor(0.36, 0.20, 0.11)
    frame:setStrokeColor(0.18, 0.10, 0.05)
    frame.strokeWidth = 3
    frame.alpha = 0
    
    return group
end

function M.new( content )
    if type(content) ~= "table" then
        return false
    end 
    
    if frameIsVisible == false then
        fadeObject( frame, true )
    end
    
    handleMessage( content )
end











return M