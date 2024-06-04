local composer = require( "composer" )
local scene = composer.newScene()

-- local loadsave = require( "scripts.loadsave" )

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		timer.performWithDelay( 100, function()
			composer.gotoScene( "scenes.game" )
		end )
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "show", scene )
-- -----------------------------------------------------------------------------------

return scene