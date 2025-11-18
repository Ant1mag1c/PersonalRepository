-- Tämä reloadScene on vain yksinkertainen "välikäsi" scene, joka lataa game scenen uudestaan. Tämä on tarpeen, koska
-- game scene on jo ladattu, joten emme voi kutsua composer.gotoScene( "Scenes.game" ) uudestaan, koska olemme jo siellä.
-- Tulemalla hetkeksi tähän sceneen, voimme poistaa game scenen ja ladata sen sitten uudestaan.

local composer = require( "composer" )
local scene = composer.newScene()

local level

function scene:create( event )
	level = event.params and event.params.level or nil
end

function scene:show( event )
    local phase = event.phase

    if ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		composer.removeScene( "Scenes.game" )

		composer.gotoScene( "Scenes.game", { effect = "fade", time = 200, params = {
			level = level
		} } )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------

return scene