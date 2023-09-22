local composer = require( "composer" )
local scene = composer.newScene()

local settings = require("Scripts.settings")
local userdata = require("Scripts.userdata")
local screen = require("Scripts.screen")
local map = require("Scripts.map")
local mapData = require("Data.mapData")
local widget = require( "widget" )
local playerStatusBar = require("Widgets.playerStatusBar")
local eventData = require("Data.eventData")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local buttonOptions
local fog

local function repeatCloudTransition()
	transition.to( fog.fill, {
		time = 10000,
		x = fog.fill.x + 1,
		y = fog.fill.y + 0.25,
		scaleX = fog.origScale * math.random(95,105)*0.01,
		scaleY = fog.origScale * math.random(95,105)*0.01,
		tag = "fogTransition",
		onComplete = repeatCloudTransition,
	})
end

local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then

		composer.showOverlay("scenes.options", {
			isModal = true,
			effect = "fade",
			time = 250,
			params = {
				fromGame = true,
			},
		})
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}

	local background = display.newImage(sceneGroup, "Resources/Images/map.png")
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	fog = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	display.addRepeatingFill( fog, "Resources/Images/smoke_test.png", 256 )
	fog.origScale = fog.fill.scaleX

	repeatCloudTransition()

	if not userdata.player then
		userdata.new()
	end

	if not userdata.player.map or not sceneParams or sceneParams.newGame then
		local whichMap = sceneParams.whichMap or 1

		if whichMap > #mapData then
			whichMap = #mapData
		end

		userdata.player.currentMap = whichMap
		userdata.player.playerPos = { path=0, step=0, level=0 }
		userdata.player.map = map.generate(mapData[whichMap], whichMap == #mapData)

		userdata.save()
	end

	map.render( sceneGroup, userdata.player.map )

	-------------------------------------------------------

	local buttonWidth = 120
	local buttonHeight = 373/1072*buttonWidth

	buttonOptions = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "Options",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = handleButtonEvent,
		font = settings.userdata.font,
		fontSize = 22,
	})
	sceneGroup:insert( buttonOptions )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	local sceneParams = event.params or {}

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

		if not sceneParams.continue then

			if sceneParams.newMap then
				userdata.player.currentMap = userdata.player.currentMap + 1
				userdata.player.playerPos = { path=0, step=0, level=0 }

				map.destroy()


				userdata.player.map = map.generate( mapData[userdata.player.currentMap], userdata.player.currentMap == #mapData )
				userdata.save()


				map.render( sceneGroup, userdata.player.map )
			end
			map.start( sceneGroup, sceneParams )

		else
			map.setState( "resume" )
		end

		playerStatusBar.create( sceneGroup, buttonOptions )
		buttonOptions:toFront()



	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		map.setState( "pause" )
		transition.pause( "fogTransition" )
		playerStatusBar.destroy()
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


function scene:destroy( event )
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	map.destroy()
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