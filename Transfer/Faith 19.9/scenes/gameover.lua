local composer = require( "composer" )
local scene = composer.newScene()

local settings = require("Scripts.settings")
local screen = require("Scripts.screen")
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


local function onButtonEvent(event)
	if event.phase == "ended" then
		composer.gotoScene("scenes.mainMenu" ,{
			time = 250,
			effect = "fade"
		})

    end
    return true
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImage( sceneGroup, "Resources/Images/gameover.png" )
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	local buttonWidth = 220
	local buttonHeight = 373/1072*buttonWidth

	local button = widget.newButton({
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		id = "backToMenu",
		label = "Back to Menu",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = onButtonEvent,
		font = settings.userdata.font,
		fontSize = 22,
	})
	button.x, button.y = screen.centerX, screen.maxY - 80
	sceneGroup:insert( button )

	-- Poista pelaajan tallennukset, ettei peliä voi jatkaa pelin loputtua.
	-- (Backup on poistettava myös, koska muuten loadsave moduuli palauttaa vanhan datan sillä.)
	local savefile = system.pathForFile( "userdata.json", system.DocumentsDirectory )
	local backup = system.pathForFile( "backup_userdata.json", system.DocumentsDirectory )
	os.remove( savefile )
	os.remove( backup )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


function scene:destroy( event )
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene