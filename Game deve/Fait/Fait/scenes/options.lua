local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local settings = require( "Scripts.settings" )
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
				end
			end
		end
	end
end

-- create()
function scene:create( event )
	local sceneGroup = self.view

	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
	background:setFillColor( 0, 0, 0, 0.5 )

	local image = display.newImageRect( sceneGroup, "Resources/Images/options.png", 424, 569 )
	image.x = display.contentCenterX
	image.y = display.contentCenterY

	local buttonWidth = 150
	local buttonHeight = 50
	local buttonPadding = 3

	-- nappuloiden tiedot taulukkoon, kaikki nappulat keskellä options.png kuvaa

	local buttondata = {
		-- sulje overlay
		{ text = "Close", id = "close", x = 475, y = image.y + image.height / 2 - buttonHeight / 2 - 25 },

		-- -- tallenna ja resetoi valinnat jätetään tältä erää pois
		-- { text = "Save options", id = "saveOptions", x = 475, y = 350 },
		-- { text = "Reset options", id = "resetOptions", x = 475, y = 250 },

		-- -- kielivalinnat jätetään tältä erää pois
		-- { text = "Language", id = "language", x = 475, y = 150 },

		-- -- ääniasetukset jätetään tältä erää pois
		-- { text = "Sound", id = "sound", x = 475, y =175 },

		-- resoluutioasetukset
		{ text = "Resolution", id = "resolution", x = 475, y = image.y + image.height / 2 - buttonHeight - 150 },
		-- fullscreen
		{ text = "Fullscreen", id = "fullscreen", x = 475, y = image.y + image.height / 2 - buttonHeight * 2.5 - 150 }
	}
	-- display nappulat ja lisää event listenerit
	for i = 1, #buttondata do
		local button = display.newRect( sceneGroup, buttondata[i].x, buttondata[i].y, buttonWidth, buttonHeight )
		button.id = buttondata[i].id
		button:setFillColor( 0.2, 0, 0 )
		button:addEventListener( "touch", onButtonEvent )
		local text = display.newText( sceneGroup, buttondata[i].text, button.x, button.y, native.systemFontBold, 16 )
	end

	-- sliderin tiedot taulukkoon
	local sliderdata = {
		-- master volume
		{ text = "Master volume", id = "masterVolume", x = image.x + image.width / 2 - 200, y = image.y + image.height / 5 - 300 , value = settings.userdata.masterVolume},
		-- music volume
		{ text = "Music volume", id = "musicVolume", x = image.x + image.width / 2 - 200, y = image.y + image.height / 5 - 200, value = settings.userdata.musicVolume},
		-- fx volume
		{ text = "FX volume", id = "fxVolume", x = image.x + image.width / 2 - 200, y = image.y + image.height / 5 - 250, value = settings.userdata.fxVolume}
	}
	-- display sliderit ja lisää event listenerit
	for i = 1, #sliderdata do
		local slider = widget.newSlider (
			{
				x = sliderdata[i].x,
				y = sliderdata[i].y,
				width = 100,
				value = sliderdata[i].value,
				listener = sliderListener
			}
		)
		sceneGroup:insert( slider )
		slider.id = sliderdata[i].id
		local text = display.newText( sceneGroup, sliderdata[i].text, slider.x - 15, slider.y, native.systemFontBold, 16 )
		text.anchorX = 1
	end
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