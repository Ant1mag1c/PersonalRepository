local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require("Scripts.screen")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local isStore = sceneParams.isStore or false
	print( "deck: isStore", isStore )

	-------------------------------------------------------

	-- Debuggaus nappula, jota käyttämällä voidaan palata karttaan.
	local debugButton = display.newText( sceneGroup, "Close Overlay", screen.minX + 10, screen.minY + 40, native.systemFont, 24 )
	debugButton.anchorX, debugButton.anchorY = 0, 0
	debugButton:setFillColor( 1, 0.9, 0 )

	debugButton:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			composer.hideOverlay( "fade", 100 )
		end
		return true
	end )

	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor(0, 0.5)

	local sceneLayer = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width/1.3, screen.height/2 )
	sceneLayer:setFillColor(0.8, 0.8, 0.5)

	local title = "shop"
	local description = "You have entered a shop"

	local titleOptions =
		{
			text = title,
			x = sceneLayer.x,
			y = sceneLayer.y*0.6,
			width = sceneLayer.x*1.5,
			font = native.systemFont,
			fontSize = 25,
			align = "left"
		}

		local descriptionOptions =
		{
			text = description,
			x = sceneLayer.x,
			y =  sceneLayer.y*0.8,
			width = sceneLayer.x*1.5,
			font = native.systemFont,
			fontSize = 25,
			align = "left"

		}

	local titleText = display.newText( titleOptions )
	titleText:setFillColor( 1, 0, 0 )
	sceneGroup:insert(titleText)

	local descriptionText = display.newText( descriptionOptions )
	descriptionText:setFillColor( 1, 0, 0 )
	sceneGroup:insert(descriptionText)





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