local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local loadsave = require( "Scripts.loadsave" )
local sfx = require( "Scripts.updateAudio" )
local widget = require( "widget" )
local shadowText = require( "Scripts.shadowText" )

local buttonBack

-- Funktio, joka kutsutaan, kun tiettyjä nappeja painetaan.
local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then
		local id = event.target.id
		print( id )

		-- Jos "back" nappia painetaan, niin siirrytään menu sceneen:
		if id == "back" then
			composer.gotoScene( "Scenes.menu", { effect = "fade", time = 500 } )

		end
	end
end

-- Funktio, joka kutsutaan, kun slidereita liikutetaan.
-- local function sliderListener( event )
-- 	-- Ajetaan alla oleva sisältö vain kun käyttäjä päästää sliderista irti.
-- 	if event.phase == "ended" then
-- 		-- print( "Slider \"" .. event.target.id .. "\" at " .. event.value .. "%" )

-- 		-- Jokaisessa sliderissa on id, joka kertoo, mikä asetus on kyseessä. Tämä id on sama kuin
-- 		-- userdata tiedoston avain, joten voimme tallentaa arvon userdataan.
-- 		loadsave.userdata[event.target.id] = event.value
-- 		loadsave.save( loadsave.userdata, "userdata.json" )

-- 		-- Kutsutaan updateAudio moduulia, joka päivittää taustamusiikin ja äänien voimakkuudet.
-- 		sfx.update()
-- 	end
-- end

-- Funktio, joka kutsutaan, kun checkboxia painetaan.
-- local function onSwitchPress( event )
--     local switch = event.target
--     -- print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )

-- 	-- Tallennetaan userdata tiedostoon, että fullscreen on päällä (tai ei ole, switch.isOn on true/false).
-- 	loadsave.userdata["fullscreen"] = switch.isOn
-- 	loadsave.save( loadsave.userdata, "userdata.json" )

-- 	-- Muutetaan pelin ikkunan koko vastaamaan fullscreen tilaa.
-- 	if switch.isOn then
	-- 		native.setProperty( "windowMode", "fullscreen" )
	-- 	else
		-- 		native.setProperty( "windowMode", "normal" )
		-- 	end
		-- end


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

	local windowBG = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, 600, 480 )
	windowBG:setFillColor( 0, 0.8 )

	shadowText.new({
		parent = sceneGroup,
		text = "LORE",
		x = display.contentCenterX,
		y = display.screenOriginY + 42,
		font = "Fonts/munro.ttf",
		fontSize = 72,
	})

	shadowText.new({
		parent = sceneGroup,
		text = "You are a brave knight of great kingdom.\nOne day during your jorney an ancient\ndragon attacked your castle. Before you\nreturned back to your castle for a defend\na hostile wizard casted a magical barrier\nblocking your way. With enough wisdom this\nbarrier can be vanished. You need to gather\ntwo spellbooks to break the barrier and return\nto your castle",
	 -- text = "------------------------------------",
		x = display.contentCenterX,
		y = 230,
		width = 10,
		font = "Fonts/munro.ttf",
		fontSize = 30,
	})

	buttonBack = widget.newButton(
		{
			x = display.contentCenterX,
			y = 600,
			id = "back",
			label = "Back",
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
	sceneGroup:insert( buttonBack )



	-- Luodaan sliderit, checkbox ja niiden yläpuolelle tekstit:

	-- local sliderMasterVolume = widget.newSlider(
	-- 	{
	-- 		x = display.contentCenterX,
	-- 		y = 180,
	-- 		id = "masterVolume",
	-- 		width = 320,
	-- 		value = loadsave.userdata["masterVolume"],
	-- 		listener = sliderListener
	-- 	}
	-- )
	-- sceneGroup:insert( sliderMasterVolume )

	-- shadowText.new({
	-- 	parent = sceneGroup,
	-- 	text = "Master Volume",
	-- 	x = display.contentCenterX,
	-- 	y = sliderMasterVolume.y - sliderMasterVolume.height - 10,
	-- 	font = "Fonts/munro.ttf",
	-- 	fontSize = 36,
	-- })

-- 	local sliderMusicVolume = widget.newSlider(
-- 		{
-- 			x = display.contentCenterX,
-- 			y = sliderMasterVolume.y + sliderMasterVolume.height + 70,
-- 			id = "musicVolume",
-- 			width = 320,
-- 			value = loadsave.userdata["musicVolume"],
-- 			listener = sliderListener
-- 		}
-- 	)
-- 	sceneGroup:insert( sliderMusicVolume )

-- 	shadowText.new({
-- 		parent = sceneGroup,
-- 		text = "Music Volume",
-- 		x = display.contentCenterX,
-- 		y = sliderMusicVolume.y - sliderMusicVolume.height - 10,
-- 		font = "Fonts/munro.ttf",
-- 		fontSize = 36,
-- 	})

-- 	local sliderSFXVolume = widget.newSlider(
-- 		{
-- 			x = display.contentCenterX,
-- 			y = sliderMusicVolume.y + sliderMusicVolume.height + 70,
-- 			id = "sfxVolume",
-- 			width = 320,
-- 			value = loadsave.userdata["sfxVolume"],
-- 			listener = sliderListener
-- 		}
-- 	)
-- 	sceneGroup:insert( sliderSFXVolume )

-- 	shadowText.new({
-- 		parent = sceneGroup,
-- 		text = "SFX Volume",
-- 		x = display.contentCenterX,
-- 		y = sliderSFXVolume.y - sliderSFXVolume.height - 10,
-- 		font = "Fonts/munro.ttf",
-- 		fontSize = 36,
-- 	})

-- 	local fullscreenCheckbox = widget.newSwitch(
-- 		{
-- 			x = 560,
-- 			y = sliderSFXVolume.y + sliderSFXVolume.height + 50,
-- 			style = "checkbox",
-- 			id = "Checkbox",
-- 			onPress = onSwitchPress,
-- 			initialSwitchState  = loadsave.userdata["fullscreen"],
-- 		}
-- 	)
-- 	sceneGroup:insert( fullscreenCheckbox )

-- 	shadowText.new({
-- 		parent = sceneGroup,
-- 		text = "Fullscreen",
-- 		x = fullscreenCheckbox.x - fullscreenCheckbox.width - 10,
-- 		y = fullscreenCheckbox.y,
-- 		anchorX = 1,
-- 		font = "Fonts/munro.ttf",
-- 		fontSize = 36,
-- 	})

end


-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		buttonBack:setEnabled( true )

    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
		buttonBack:setEnabled( false )

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