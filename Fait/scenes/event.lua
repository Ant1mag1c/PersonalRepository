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
local eventData = require("Data.eventData")
local widget = require("widget")


local options
local actions
local result
local bounds

local optionChosen = false

local window, eventGroup
local createEvent, removeEvent, chooseOption, onMouseEvent


local title, description, image
local thisEvent

local isHiglighted = false

local imageWidth = 280
local imageHeight = 280
local mouseX = 0
local mouseY = 0
local optionTextY
local optionTextDefaultY = optionTextY

local quaranteedEvents


local function createText( text, x, y, width, font, fontSize, align)

	textOptions =

	{
		text = text,
		x = x or screen.centerX,
		y = y or screen.centerY,
		width = width or 500,
		font = settings.userdata.font,
		fontSize = fontSize or 60,
		align = align or "left"
	}

	local text = display.newText( textOptions )

	return text
end

function removeEvent()
	-- print("REMOVED WINDOW")
	display.remove( eventGroup )
	eventGroup = nil
	eventWindow = nil

end

function chooseOption( event )
	local target = event.target

	if event.phase == "ended" then
		if not optionChosen then
			optionChosen = true
			local result, nextScene = target.action()

			if result then
				eventWindow.layer:toFront()


				local resultText = createText( result, screen.centerX+30, screen.centerY, eventWindow.layer.x*1.5, font, 45, align )
					eventGroup:insert( resultText )

				resultText.backGround = display.newRect( resultText.x, resultText.y, 0, 0 )
					resultText.backGround.alpha = 0.5
					resultText.backGround:setFillColor(0.1)
					resultText.backGround.height, resultText.backGround.width = resultText.height, resultText.width

					eventGroup:insert( resultText.backGround )

					resultText:toFront()

					local continueButton = widget.newButton( {
						label = "Continue",
						fontSize = 30,
						labelColor = { default={ 1, 1, 0 }, over= { 1, 0, 0, 0.5 } },
						onRelease = function()
							removeEvent()

							if nextScene then
								local newScene = eventData[nextScene]
								thisEvent = newScene
								optionChosen = false

								createEvent()

							else
								-- Sulje scene
								composer.hideOverlay( "fade", 250 )
							end

						end
					} )

					continueButton.x, continueButton.y = screen.centerX, eventWindow.layer.height
					eventGroup:insert( continueButton )
			end
			-- Jos eventti antaa pelaajalle taattuja hyviä eventtejä niin lisätään
			-- hyvien eventtien tauluun haluttu määrä hyviä eventtejä ja varmistetaan
			-- etteivät hyvät eventit ole duplikaatteja
		if userdata.player.goodEventCount > 0 then
			for i = 1, userdata.player.goodEventCount do
				thisEvent = table.getRandom(eventData)

				if i == 1 then
					repeat
						thisEvent = table.getRandom(eventData)
					until thisEvent.isPositiveEvent == true

				else
					repeat
						thisEvent = table.getRandom(eventData)
					until thisEvent.isPositiveEvent == true and thisEvent ~= quaranteedEvents[1]
				end

					table.insert( quaranteedEvents, thisEvent )
					userdata.player.goodEventCount = userdata.player.goodEventCount - 1
					print( "Quaranteed event in value " .. i .. " is " .. quaranteedEvents[i].title )
			end
		end


		else
			return
		end


	-- Päivitetään ruudun yläreunassa olevat pelaajan statsit,
	-- sillä ne todennäköisesti muuttuivat eventin seurauksena.
	playerStatusBar.update()


	end
	return true

end





function createEvent()
	eventWindow = {}

	options = {}
	actions = {}
	result = {}
	bounds = {}

	print("Luodaan uusi ikkuna " .. thisEvent.title)


	title = thisEvent.title
	description = thisEvent.description
	image = thisEvent.image

	for k,v in pairs (thisEvent.event) do
		-- print(k,v)
		for i = 1, k do
			options[i] = thisEvent.event[i]
			actions[i] = thisEvent.event[i].action
			result[i] = thisEvent.event[i].result

			options[i].text = {}
		end
	end

	-- print( "Luodaan tapahtuma: ",  thisEvent )

	eventGroup = display.newGroup()

	eventWindow.layer = display.newImageRect( eventGroup, "Resources/Images/eventMenu.png", 920, 480 )
	eventWindow.layer.x, eventWindow.layer.y = screen.centerX, screen.centerY


	-- Ladataan eventille henkilökohtainen kuva ja ellei sitä löydy käytetään
	-- sen sijaan oletuskuvaa
	local layerImage = display.newImageRect( eventGroup, "Resources/Images/Events/" .. image,  imageWidth, imageHeight )

	if not layerImage then
		layerImage = display.newImageRect( eventGroup, "Resources/Images/Events/blackberries.png", imageWidth, imageHeight )

		-- TODO: ota nuo alemmat rivit pois kommenteista kun Emma on saanut testailtua taustakuvia, ettei vielä häiritä sitä tehtävää.
 		-- print( "WARNING: Kuvaa ei löytynyt, käytetään oletuskuvaa ja lisätään punainen huomioväritys.")
		-- layerImage:setFillColor( 1, 0, 0 )

	end

	layerImage.x, layerImage.y = 230, 360

		local titleText = createText( title, layerImage.x, layerImage.y*0.4, 600, font, fontSize, align)
			titleText.anchorX, titleText.anchorY = 0.3, 0.5
			eventGroup:insert( titleText )

		local descriptionText = createText( description, layerImage.x*1.8, layerImage.y*0.6, layerImage.imageWidth, font, 24, align )
			descriptionText.anchorX, descriptionText.anchorY = 0, 0
			eventGroup:insert( descriptionText )

			optionTextY = descriptionText.y*1.9


	for i = 1, #options do
		local optionText = options[i]
		local bounds = bounds[i]

		optionText.text = createText( options[i].option, screen.centerX-70, optionTextY-50, width, settings.userdata.font, 30, align )
		optionText.text.anchorX = 0
		optionText.text.alpha = 0.8

		optionText.text.window = display.newRect( eventGroup, options[i].text.x, options[i].text.y, 450, 35 )
		optionText.text.window.alpha = 0.5
		optionText.text.window:setFillColor(0.1)
		optionText.text.window.anchorX = 0
		optionText.text.action = actions[i]
		optionText.text.result = result[i]
		optionText.text:addEventListener("touch", chooseOption)
		eventGroup:insert( optionText.text )

		bounds = optionText.text.window.contentBounds

		optionTextY = optionTextY + 60

	end

	optionTextY = optionTextDefaultY

end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	quaranteedEvents = userdata.player.quaranteedEvents

	sceneParams = event.params or {}
	eventType = sceneParams.type


	if not userdata.player then
		userdata.new()
	end



	-- Katsotaan onko eventti randomEvent vai joku muu ja annetaan parametrit sen mukaisesti
	if not quaranteedEvents[1] then
		if sceneParams.type == "randomEvent" then
			thisEvent = table.getRandom( eventData )
		else
			thisEvent = eventData[sceneParams.type]
		end
	else
		thisEvent = quaranteedEvents[1]

	end

	createEvent()
	-- Jos pelaajalla on taattuja hyviä eventtejä niin aina hyvään eventtiin siirtyessä
	-- poistetaan hyvien eventtien taulusta nykyinen eventti

	if quaranteedEvents[1] then
		for i = 1, #quaranteedEvents - 1 do
			quaranteedEvents[i] = quaranteedEvents[i + 1]
		end

		quaranteedEvents[#quaranteedEvents] = nil

		if quaranteedEvents[1] then
			print("Next quranteed event: ", quaranteedEvents[1].title)
		else
			print("No more quranteed events")
		end
	end










-- 	local function onMouseEvent(event)
-- 		mouseX, mouseY = event.x, event.y
-- 	end


-- 	local isHighlighted = false
-- 	local target
-- 	local prevTarget

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


	-- Runtime:addEventListener( "mouse", onMouseEvent )
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
