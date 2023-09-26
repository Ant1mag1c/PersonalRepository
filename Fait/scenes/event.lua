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
local bounds = {}
-- local text
local popupTitle = {}
local optionChosen = false


-- Ajetaan pelaajan valitsemalle vaihtoehdolle eventData taulussa oleva funktio
local function chooseOption(event)
	local target = event.target
	if event.phase == "ended" then
		if not optionChosen then
			optionChosen = true
			target.action()
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

	local mouseX = 0
	local mouseY = 0
	local isHiglighted = false

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

			options[i].text = {}
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

	local optionTextY = screen.centerY + 95


	for i = 1, #options do

		options[i].text = display.newText( sceneGroup, options[i].option, screen.centerX-70, optionTextY, settings.userdata.font, 30 )
		options[i].text.anchorX = 0
		options[i].text.alpha = 0.8

		options[i].text.window = display.newRect( sceneGroup, options[i].text.x, options[i].text.y, 450, 35 )
		options[i].text.window.alpha = 0.5
		options[i].text.window:setFillColor(0.1)
		options[i].text.window.anchorX = 0

		bounds[i] = options[i].text.window.contentBounds

		options[i].text:toFront()
		options[i].text.action = actions[i]
		options[i].text.result = result[i]

		options[i].text:addEventListener("touch", chooseOption)

		optionTextY = optionTextY + 60


	end



	local function onMouseEvent(event)
		mouseX, mouseY = event.x, event.y
	end


	local isHighlighted = false
	local target
	local prevTarget

	-- TODO: Koodi ei toimi ensimmäisen optionin kohdalla..
	-- Selvitä miksi
	-- local function highlightOption()

	-- 	for i = 1, #options do
	-- 		if bounds[i].xMin < mouseX and bounds[i].xMax > mouseX and
	-- 			bounds[i].yMin < mouseY and bounds[i].yMax > mouseY then

	-- 			isHighlighted = true
	-- 			target = options[i].text
	-- 			target.id = i
	-- 			target:setFillColor(1,0,0)

	-- 			prevTarget = target

	-- 			-- print(target.id)

	-- 		else

	-- 			if isHighlighted then
	-- 				prevTarget:setFillColor(1,1,1)
	-- 				isHighlighted = false
	-- 			end

	-- 		end

	-- 	end
	-- end

	-- options[1].text:setFillColor(0,0,0)


	Runtime:addEventListener( "mouse", onMouseEvent )
	-- Runtime:addEventListener("enterFrame", highlightOption)
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
