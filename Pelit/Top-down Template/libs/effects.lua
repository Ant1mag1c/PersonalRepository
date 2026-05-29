-- Useful in-game and ui effects to  use globally

local screen = require( "classes.screen" )
local controls = require("classes.controls")
local debug = require("classes.debug")

local ui = {}

-- Dimmer background (blocks touches from propagating through).
function ui:getDimmer(denyBlock)
    local newGroup = display.newGroup()

    local dimmer = display.newRect( newGroup, screen.centerX, screen.centerY, screen.width, screen.height )
    dimmer:setFillColor( 0, 0.6 )

    if not denyBlock then
        dimmer:addEventListener( "touch", function() return true end )
        dimmer:addEventListener( "tap", function() return true end )
    end
    
    if debug.debugPrints then print( "controls stop called from effects" ) end
    return newGroup
end

return ui