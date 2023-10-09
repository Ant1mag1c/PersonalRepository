-- local screen = require("scripts.screen")

-- local map = {}

-- local columCount = 5
-- local rowCount = 3
-- local spacing = 20

-- local rowWidth = screen.width / rowCount

-- local debugLine = {}

-- local widget = require( "widget" )


-- local debugG = display.newGroup()

-- for i = 1, 1 do
--     local fromX, fromY, toX, toY = screen.centerX, 0, screen.centerX, screen.height


--     -- x1,y1,x2,y2
--     debugLine = display.newLine( debugG, fromX, fromY, toX, toY  )
--     debugLine.strokeWidth = 3
-- end

-- local options =

-- {
--     x, y = screen.centerX, screen.centerY,
--     id = "HI"


-- }




-- local button = widget.newButton( options )



local widget = require("widget")

-- Function to handle button events
local function handleButtonEvent(event)
    if ("ended" == event.phase) then
        -- Handle the button press event
        print("Button pressed!")
    end
end

-- Function to create a button with a specific label
local function createButton(label)
    local options = {
        label = label,
        onEvent = handleButtonEvent,
        emboss = false,
        shape = "rectangle",
        width = 200,
        height = 40,
        cornerRadius = 8,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0.5 } },
        fillColor = { default={ 0.2, 0.2, 0.8, 1 }, over={ 0.1, 0.1, 0.6, 0.7 } }
    }

    -- Create a button
    local button = widget.newButton(options)

    -- Position the button
    button.x = display.contentCenterX
    button.y = display.contentCenterY

    return button
end

-- Create a button with the label "Press Me"
local button1 = createButton("Press Me")

-- Create a button with a different label
local button2 = createButton("Click Me")

-- You can create as many buttons as needed with different labels
