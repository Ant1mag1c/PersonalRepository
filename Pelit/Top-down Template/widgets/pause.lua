---------------------------------------------------------------------------
-- Pause Menu Widget
-- A display group based pause menu (not a Composer scene).
-- Blocks all touch propagation behind it.
---------------------------------------------------------------------------

local screen = require( "classes.screen" )
local widget = require( "widget" )

local M = {}

---------------------------------------------------------------------------

function M.new( params )
    params = params or {}

    local onResume = params.onResume
    local onSave = params.onSave
    local onLoad = params.onLoad
    local onOptions = params.onOptions
    local onQuit = params.onQuit

    local group = display.newGroup()
    local buttons = {}

    -----------------------------------------------------------------------
    -- Dimmer background (blocks touches from propagating through).

    local dimmer = display.newRect( group, screen.centerX, screen.centerY, screen.width, screen.height )
    dimmer:setFillColor( 0, 0.5 )
    dimmer:addEventListener( "touch", function() return true end )
    dimmer:addEventListener( "tap", function() return true end )

    -----------------------------------------------------------------------
    -- Window.

    local window = display.newRect( group, screen.centerX, screen.centerY, 160, 220 )
    window:setFillColor( 0, 0.9 )

    -----------------------------------------------------------------------
    -- Title.

    local title = display.newText({
        parent = group,
        text = "Paused",
        fontSize = 20,
        font = native.systemFontBold,
    })
    title.x = screen.centerX
    title.y = window.y - window.height * 0.5 + title.height * 0.5 + 10

    -----------------------------------------------------------------------
    -- Buttons.

    local buttonData = {
        { id = "resume",  label = "Resume",       callback = onResume },
        { id = "save",    label = "Save",          callback = onSave },
        { id = "load",    label = "Load",          callback = onLoad },
        { id = "options", label = "Options",       callback = onOptions },
        { id = "quit",    label = "Quit to Menu",  callback = onQuit },
    }

    local startY = title.y + title.height * 0.5 + 20

    for i, data in ipairs( buttonData ) do
        local cb = data.callback
        buttons[data.id] = widget.newButton({
            x = screen.centerX,
            y = startY + (i - 1) * 32,
            id = data.id,
            label = data.label,
            labelAlign = "center",
            labelColor = { default = { 0.9 }, over = { 1 } },
            onEvent = function( event )
                if event.phase == "ended" then
                    if cb then cb() end
                end
                return true
            end,
            width = 120,
            height = 26,
            fontSize = 14,
            font = native.systemFontBold,
            shape = "rect",
            fillColor = { default = { 0, 0.7 }, over = { 0, 0.9 } },
        })
        group:insert( buttons[data.id] )
    end

    -----------------------------------------------------------------------
    -- Key listener: Escape closes the pause menu.

    local function onKey( event )
        if event.keyName == "escape" and event.phase == "down" then
            if onResume then onResume() end
            return true
        end
        return false
    end

    Runtime:addEventListener( "key", onKey )

    -----------------------------------------------------------------------
    -- Disable the widget (suspend key listener and buttons).
    -- Used when showing an overlay on top of the pause menu.

    function group:disable()
        Runtime:removeEventListener( "key", onKey )
        for _, btn in pairs( buttons ) do
            btn:setEnabled( false )
        end
    end

    -----------------------------------------------------------------------
    -- Enable the widget (restore key listener and buttons).

    function group:enable()
        Runtime:addEventListener( "key", onKey )
        for _, btn in pairs( buttons ) do
            btn:setEnabled( true )
        end
    end

    -----------------------------------------------------------------------
    -- Destroy method.

    function group:destroy()
        Runtime:removeEventListener( "key", onKey )
        for _, btn in pairs( buttons ) do
            btn:setEnabled( false )
        end
        display.remove( group )
    end

    return group
end

---------------------------------------------------------------------------

return M
