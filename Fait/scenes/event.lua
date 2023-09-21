local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local settings = require("Scripts.settings")
local userdata = require("Scripts.userdata")
local screen = require("Scripts.screen")
local playerStatusBar = require("Widgets.playerStatusBar")

local dataHandler = require("Scripts.dataHandler")
-- local eventData = dataHandler.getData( "events.tsv" )
local eventData = require("Data.eventData")
local options = {}
local actions = {}
local result = {}
local popupTitle = {}
local optionChosen = false


-- Ajetaan pelaajan valitsemalle vaihtoehdolle eventData taulussa oleva funktio
local function chooseOption(event)
	local target = event.target
	if event.phase == "ended" then
		if not optionChosen then
			optionChosen = true
			target.action()
			local playerHP = userdata.player.sisuCurrent

			userdata.takeDamage(playerHP, 30)
			userdata.save()
			-- Päivitetään ruudun yläreunassa olevat pelaajan statsit,
			-- sillä ne todennäköisesti muuttuivat eventin seurauksena.
			playerStatusBar.update()

			-- Tarkistetaan onko valitulla vaihtoehdolla "string" muotoinen result ja jos on niin
			-- luodaan uusi ikkuna jolla result näytetään.
			-- Jos resultia ei ole, eventti avaa uuden näkymän esim kauppaan

			window.layer:toFront()

			if type(target.result) == "string" then
				local resultText = display.newText( {text = target.result, x = screen.centerX, y = window.layer.y*0.82} )
				-- resultText:setFillColor()
				-- TODO: Lisää resultTextille taustan vastaväri

				timer.performWithDelay( 1500, function()
					composer.hideOverlay( "fade", 250 )
						display.remove( resultText )
							end )

			else
				composer.hideOverlay( "fade", 250 )

			end

		else
			return
		end


	end
	return true
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}
	local eventType = sceneParams.type
	print( "Luodaan tapahtuma: " .. eventType )

	if not userdata.player then
		userdata.new()
	end

	-- Luodaan ikkuna jonka sisällä eventti näytetään
	window = {}

	window.bg = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	window.bg:setFillColor(0, 0.5)

	window.layer = display.newImageRect( sceneGroup, "Resources/Images/options.png", screen.width, screen.height/1.5 )
	window.layer.x, window.layer.y = screen.centerX, screen.centerY

	window.imageBorder = display.newImageRect( sceneGroup, "Resources/Images/menu.png", 280, 280 )
	window.imageBorder.x, window.imageBorder.y = screen.centerX*0.5, screen.centerY*1.1


	local title, description, image
	local thisEvent

	-- Katsotaan onko eventti randomEvent vai joku muu ja annetaan parametrit sen mukaisesti
	if sceneParams.type == "randomEvent" then
		thisEvent = table.getRandom( eventData )

	else
		thisEvent = eventData[sceneParams.type]
	end

	title = thisEvent.title
	description = thisEvent.description
	image = thisEvent.image

	-- Tarkistetaan montako valittavaa vaihtoehtoa eventillä on ja lisätään ne omiin tauluihinsa
	for k,v in pairs (thisEvent.event) do
		-- print(k,v)
		for i = 1, k do
			options[i] = thisEvent.event[i]
			actions[i] = thisEvent.event[i].action
			result[i] = thisEvent.event[i].result
		end
	end

	titleOptions =
	{
		text = title,
		x = window.layer.x+10,
		y = window.layer.y*0.5,
		width = window.layer.x*1.63,
		font = settings.userdata.font,
		fontSize = 40,
		align = "left"
	}

	descriptionOptions =
	{
		text = description,
		x = window.layer.x*1.33,
		y =  window.layer.y*0.82,
		width = window.layer.x,
		font = settings.userdata.font,
		fontSize = 25,
		align = "left"

	}


	local titleText = display.newText( titleOptions )
	sceneGroup:insert(titleText)


	-- Eventin kuvien koko erojen vuoksi muokataan jokaisen kuvan ominaisuuksia suoraan eventin taulukosta
	local imageWidth = thisEvent.imageSize.imageWidth
	local imageHeight = thisEvent.imageSize.imageHeight
	local anchorY = thisEvent.imageSize.anchorY

	-- Ladataan eventille henkilökohtainen kuva ja ellei sitä löydy käytetään
	-- sen sijaan oletuskuvaa
	local layerImage = display.newImageRect( sceneGroup, "Resources/Images/Levels/" .. image,  imageWidth, imageHeight )


	if not layerImage then
		layerImage = display.newImageRect( sceneGroup, "Resources/Images/Levels/randomEvent.png", imageWidth, imageHeight )
		anchorY = 0.5
	end

	layerImage.x, layerImage.y = window.imageBorder.x-10, window.imageBorder.y-70
	layerImage.anchorY = anchorY

	local infoText = display.newText( descriptionOptions )
	sceneGroup:insert( infoText )

	-- Luodaan eventin vaihtoehdoista omat painikkeet
	for i = 1, #options do
		local text = display.newText( sceneGroup, options[i].option, screen.centerX-70, screen.centerY+(i*60), settings.userdata.font, 30 )
		text.anchorX = 0

		text.window = display.newRect( sceneGroup, text.x*1.39, text.y, 350, 35 )
		text.window.alpha = 0.4
		text.window:setFillColor(0.1)

		text:toFront()
		text.action = actions[i]
		text.result = result[i]

		text:addEventListener("touch", chooseOption)

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
