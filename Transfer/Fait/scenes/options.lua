local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local settings = require( "Scripts.settings" )
local screen = require( "Scripts.screen" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- overlayClosed muuttuja jolla saadaan tietää onko overlay suljettu vai ei
local overlayClosed = false

----------
-- Scene event functions
-----------------------------------------------------------------------------------
-- funktionit joiden avulla saadaan slaiderit toimimaan
-----------------------------------------------------------------------------------
-- slider listener
local function sliderListener( event )
	if not overlayClosed then
		local target = event.target

		-- -- tulosta kaikki event tiedot konsoliin, !!! jotakin jännää debuggausta varten !!! K = Key, V = Value
		-- for k, v in pairs( event ) do
		-- 	print( k, v )
		-- end

		-- tallenna asetukset userdata taulukkoon ja tulosta asetukset konsoliin
		settings.userdata[target.id] = event.value
		if event.phase == "ended" then
			settings.setAudio()
			-- TODO: soita testiääni uudella asetetulla slider valuella kun event.phase == "ended" eli kun slideria ei enää kosketa
			-- audio.play( audio.loadSound( "Resources/Audio/Effects/coin.wav" ), { channel = 1, loops = 0, fadein = 0 } )

		end
	end
end


-- -----------------------------------------------------------------------------------
-- funtionit joiden avulla saadaan nappulat toimimaan
-- -----------------------------------------------------------------------------------
local function onButtonEvent( event )
	if not overlayClosed then
		if event.phase == "began" then
			local id = event.target.id
			print( id )

			if ( id == "close" ) then
				settings.save()
				overlayClosed = true
				composer.hideOverlay( "fade", 250 )
			else

				if id == "resetOptions" then
					-- print( "reset options" )
				elseif id == "saveOptions" then
					-- print( "save options" )
				elseif id == "language" then
					-- print( "language" )
				elseif id == "sound" then
					-- print( "sound" )
				elseif id == "resolution" then
					-- print( "resolution" )
				elseif id == "fullscreen" then
					-- print( "fullscreen" )
				elseif id == "backToMenu" then
					-- print( "back to menu" )
					overlayClosed = true
					composer.hideOverlay( "fade", 250 )
					composer.gotoScene( "scenes.mainMenu", { time = 250, effect = "fade" } )
				end
			end
		end
	end
end

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}
	-- for i, v in pairs( sceneParams ) do
	-- 	print( i, v )
	-- end


	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
	background:setFillColor( 0, 0, 0, 0.5 )

	local window = display.newImageRect( sceneGroup, "Resources/Images/options.png", 424, 569 )
	window.x = display.contentCenterX
	window.y = display.contentCenterY

	local title = display.newText( sceneGroup, "Options", window.x, window.y - window.height / 2 + 56, native.systemFont, 32 )

	local buttonWidth = 160
	local buttonHeight = 373/1072*buttonWidth

	-- nappuloiden tiedot taulukkoon, kaikki nappulat keskellä options.png kuvaa
	local buttondata = {
		-- -- tallenna ja resetoi valinnat jätetään tältä erää pois
		-- { text = "Save options", id = "saveOptions", x = 475, y = 350 },
		-- { text = "Reset options", id = "resetOptions", x = 475, y = 250 },

		-- -- kielivalinnat jätetään tältä erää pois
		-- { text = "Language", id = "language", x = 475, y = 150 },

		-- -- ääniasetukset jätetään tältä erää pois
		-- { text = "Sound", id = "sound", x = 475, y =175 },

		-- fullscreen
		{ text = "Fullscreen", id = "fullscreen", x = 475, y = window.y + window.height / 2 - buttonHeight - 150 },

		-- resoluutioasetukset
		{ text = "Resolution", id = "resolution", x = 475, y = window.y + window.height / 2 - 150 },

		-- sulje overlay
		{ text = "Close", id = "close", x = 475, y = window.y + window.height / 2 - buttonHeight / 2 - 25 },
	}

	-- Jos tullaan pelistä, niin lisätään "back to menu" nappula.
	if sceneParams.fromGame then
		table.insert( buttondata, { text = "Back to menu", id = "backToMenu", x = 475, y = window.y + window.height / 2 - buttonHeight * 2.53 - 150 } )
	end

	-- display nappulat ja lisää event listenerit
	for i = 1, #buttondata do
		local button = widget.newButton({
			width = buttonWidth,
			height = buttonHeight,
			defaultFile = "Resources/Images/generalbutton1.png",
			overFile = "Resources/Images/generalbutton.png",
			id = buttondata[i].id,
			label = buttondata[i].text,
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = onButtonEvent
		})
		button.x, button.y = buttondata[i].x, buttondata[i].y
		sceneGroup:insert( button )
	end

	-- sliderin tiedot taulukkoon
	local sliderdata = {
		-- master volume
		{ text = "Master volume", id = "masterVolume", x = window.x + window.width / 2 - 120, y = window.y + window.height / 5 - 280 , value = settings.userdata.masterVolume},
		-- music volume
		{ text = "Music volume", id = "musicVolume", x = window.x + window.width / 2 - 120, y = window.y + window.height / 5 - 180, value = settings.userdata.musicVolume},
		-- fx volume
		{ text = "FX volume", id = "fxVolume", x = window.x + window.width / 2 - 120, y = window.y + window.height / 5 - 230, value = settings.userdata.fxVolume}
	}

	local options = {
		frames = {
			{ x=0, y=0, width=36, height=64 },
			{ x=40, y=0, width=36, height=64 },
			{ x=80, y=0, width=36, height=64 },
			{ x=124, y=0, width=36, height=64 },
			{ x=168, y=0, width=64, height=64 }
		},
		sheetContentWidth = 232,
		sheetContentHeight = 64
	}
	local sliderSheet = graphics.newImageSheet( "Resources/Images/Slidertest1.png", options )

	-- display sliderit ja lisää event listenerit
	for i = 1, #sliderdata do
		local slider = widget.newSlider ({
			sheet = sliderSheet,
			leftFrame = 1,
			middleFrame = 2,
			rightFrame = 3,
			fillFrame = 4,
			frameWidth = 36,
			frameHeight = 64,
			handleFrame = 5,
			handleWidth = 64,
			handleHeight = 64,
			orientation = "horizontal",
			x = sliderdata[i].x,
			y = sliderdata[i].y,
			width = 200,
			value = sliderdata[i].value,
			listener = sliderListener
		})
		slider.id = sliderdata[i].id
		slider:scale(0.8, 0.8)
		sceneGroup:insert( slider )

		local text = display.newText( sceneGroup, sliderdata[i].text, slider.x + 4, slider.y + slider.height*0.5*slider.yScale, native.systemFontBold, 16 )
		text.anchorX = 1
	end


	overlayClosed = false
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