local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local widget = require( "widget" )
local shadowText = require( "Scripts.shadowText" )

local buttonPlay
local buttonOptions
local buttonExit
local sfxIntro = audio.loadSound("Audio/intro.mp3")

-- Function to handle button events
local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then
		local id = event.target.id
		-- print( id )

		if id == "play" then
			composer.gotoScene( "Scenes.game", { effect = "fade", time = 0, params = {
					level = "test"
				} } )

		elseif id == "options" then
			composer.gotoScene( "Scenes.options", { effect = "fade", time = 500 } )

		elseif id == "exit" then
			native.requestExit()

		end

	end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImage( sceneGroup, "Images/menuBG.png", display.contentCenterX, display.contentCenterY )

	local widthScale = display.actualContentWidth / background.width
	local heightScale = display.actualContentHeight / background.height

	local scale = math.max( widthScale, heightScale )
	background:scale( scale, scale )

	local text, textShadow = shadowText.new({
		parent = sceneGroup,
		text = "DRAGONSCAPE",
		x = display.contentCenterX,
		y = display.screenOriginY + 42,
		font = "Fonts/munro.ttf",
		fontSize = 72,
	})

	-- shadowText.new({
	-- 	parent = sceneGroup,
	-- 	text = "Teemu",
	-- 	x = display.contentCenterX,
	-- 	y = text.y + text.height*0.5 + 42,
	-- 	font = "Fonts/munro.ttf",
	-- 	fontSize = 40,
	-- })

	-- Create the widget
	buttonPlay = widget.newButton(
		{
			x = display.contentCenterX,
			y = 360,
			id = "play",
			label = "Play",
			labelAlign = "center",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = handleButtonEvent,
			fontSize = 48,
			font = "Fonts/munro.ttf",
			shape = "rect",
			fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
			isEnabled = false,
		}
	)
	sceneGroup:insert( buttonPlay )

	buttonOptions = widget.newButton(
		{
			x = display.contentCenterX,
			y = buttonPlay.y + buttonPlay.height + 20,
			id = "options",
			label = "Guide",
			labelAlign = "center",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = handleButtonEvent,
			fontSize = 48,
			font = "Fonts/munro.ttf",
			shape = "rect",
			fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
			isEnabled = false,
		}
	)
	sceneGroup:insert( buttonOptions )

	buttonExit = widget.newButton(
		{
			x = display.contentCenterX,
			y = buttonOptions.y + buttonOptions.height + 20,
			id = "exit",
			label = "Exit",
			labelAlign = "center",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = handleButtonEvent,
			fontSize = 48,
			font = "Fonts/munro.ttf",
			shape = "rect",
			fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
			isEnabled = false,
		}
	)
	sceneGroup:insert( buttonExit )

end


-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

		-- Tehdään napeista painettavia, kun scene on kokonaan näkyvissä, ettei pelaaja paina niitä vahingossa.
		buttonPlay:setEnabled( true )
		buttonOptions:setEnabled( true )
		buttonExit:setEnabled( true )

		audio.play( sfxIntro )
    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

		-- Poistetaan napit käytöstä heti kun scene alkaa vaihtua, ettei pelaaja voi painaa niitä useasti.
		buttonPlay:setEnabled( false )
		buttonOptions:setEnabled( false )
		buttonExit:setEnabled( false )

		for i = 2, 32 do
			audio.stop( i )
		end




    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
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