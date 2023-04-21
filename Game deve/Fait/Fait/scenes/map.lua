local composer = require( "composer" )
local scene = composer.newScene()

local screen = require("Scripts.screen")
local loadsave = require( "Libs.loadsave" )
local map = require("Scripts.map")
local mapData = require("Data.mapData")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local userdata


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}

	userdata = loadsave.load( "userdata.json", "cardevala" )

	if not userdata or not sceneParams or sceneParams.newGame then
		local whichMap = sceneParams.whichMap or 1

		if whichMap > #mapData then
			whichMap = #mapData
		end

		userdata = {
			currentMap = whichMap,
			playerPos = { path=0, step=0, level=0 },
			map = map.generate(mapData[whichMap], whichMap == #mapData)
		}

		loadsave.save( userdata, "userdata.json", "cardevala" )
	end

	map.render( sceneGroup, userdata.map )

	-------------------------------------------------------

	-- Debuggaus nappula, jota käyttämällä voidaan palata main menuun.
	local debugButton = display.newText( sceneGroup, "Return to menu", screen.minX + 10, screen.minY + 10, native.systemFont, 24 )
	debugButton.anchorX, debugButton.anchorY = 0, 0
	debugButton:setFillColor( 1, 0.9, 0 )

	debugButton:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			map.destroy()

			local options = {
				effect = "fade",
				time = 250,
			}

			composer.gotoScene( "scenes.mainMenu", options )
		end
		return true
	end )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	local sceneParams = event.params or {}

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		if not sceneParams.continue then

			if sceneParams.newMap then
				userdata.currentMap = userdata.currentMap + 1
				userdata.playerPos = { path=0, step=0, level=0 }

				map.destroy()


				userdata.map = map.generate( mapData[userdata.currentMap], userdata.currentMap == #mapData )
				loadsave.save( userdata, "userdata.json", "cardevala" )


				map.render( sceneGroup, userdata.map )
			end
			map.start( sceneGroup, sceneParams )

		else
			map.setState( "resume" )
		end

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		map.setState( "pause" )
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