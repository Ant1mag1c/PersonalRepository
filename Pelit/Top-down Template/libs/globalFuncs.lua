local widget = require("widget")
local screen = require("classes.screen")

local funcs = {}

-- Create new widget button with callback and 
function funcs:newButton(params)
    local button = widget.newButton({
        x = params.x or screen.centerX,
        y = params.y or screen.centerY,
        width = params.width or 200,
        height = params.height or 50,

        id = params.id or "btn",
        label = params.label or "Button",

        shape = params.shape or "roundedRect",
        cornerRadius = params.cornerRadius or 8,

        fillColor = params.fillColor or {
            default = { 67/255, 67/255, 153/255 }, over = { 67/255, 67/255, 153/255 },
        },

        labelColor = params.labelColor or {
            default = {1,1,1}, over = {1,1,1}
        },
        
        strokeWidth = 3,
        strokeColor = params.strokeColor or { default={ 0.29, 0.17, 0.10 }, over={ 0.29, 0.17, 0.10 } },

        fontSize = params.fontSize or 20,
        font = "assets/fonts/fonts/munro.ttf",

        onPress = params.onPress,
        onRelease = params.onRelease
    })

    if params.parent then params.parent:insert(button) end
    
    button.isEnabled = true

    button:addEventListener("touch", function (e)
        if not button.isEnabled then return end
        if e.phase == "began" then
            button:scale(0.9, 0.9)
        elseif e.phase == "ended" then
            button:scale(1.1, 1.1)
            if params.isSwitch then button.isEnabled = false end
            if params.callback then params.callback() end
        end 
    end )

    return button
end












return funcs