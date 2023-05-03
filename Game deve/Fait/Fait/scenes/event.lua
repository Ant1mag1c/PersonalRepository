local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local userdata = require("Scripts.userdata")
local screen = require("Scripts.screen")

local dataHandler = require("Scripts.dataHandler")
local eventData = dataHandler.getData( "events.tsv" )
local options = {}
local actions = {}
local result = {}
local popupTitle = {}


asdasd
-- Handler that gets notified when the alert closes
local function onComplete( event )
	if ( event.action == "clicked" ) then
		composer.hideOverlay( "fade", 100 )
		print("Player money: ", userdata.player.money)
		print("Player sisuMax: ", userdata.player.sisuMax)
		-- print("Player sisu: ", userdata.player.sisu)
	end
end

local function chooseOption(event)
	local target = event.target
	if event.phase == "ended" then

		-- Luo globaali taulukko johon laitetaan pelaajan data
		-- Sitten muokataan sitä, tallennetaan data ja poistetaan se
		_G.tempData = userdata.player
		local s = string.gsub( target.action, "($)", "_G.tempData." )
		local f = loadstring(s)
		f()

		_G.tempData = nil
		userdata.save()

		-- Avaa ponnahdusikkunan annetuilla tiedoilla
		local alert = native.showAlert( target.popupTitle, target.result, { "OK" }, onComplete )

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

	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor(0, 0.5)

	local sceneLayer = display.newImageRect( sceneGroup, "Resources/Images/options.png", screen.width, screen.height/1.5 )
	sceneLayer.x, sceneLayer.y = screen.centerX, screen.centerY

	local imageBorder = display.newImageRect( sceneGroup, "Resources/Images/menu.png", 280, 280 )
	imageBorder.x, imageBorder.y = screen.centerX*0.5, screen.centerY*1.1


	local title, description, image

	local thisEvent

	-- Katsotaan onko eventti randomEvent vai joku muu ja annetaan parametrit sen mukaisesti
	if sceneParams.type == "randomEvent" then
		thisEvent = table.getRandom( eventData )

	else
		thisEvent = eventData[sceneParams.type]
	end


	-- for k,v in pairs(sceneParams) do
	-- 	print( k, v )
	-- end

	-- Valitaan satunnainen tapahtuma, joka löytyy eventDatasta, ja luodaan sille näkymä.

	-- table.print( thisEvent )
	title = thisEvent.title
	description = thisEvent.description
	image = thisEvent.image

	table.print(thisEvent)

	for i = 1,3 do
		local _option = thisEvent["option" .. i]
		local _action = thisEvent["action" .. i]
		local _result = thisEvent["result" .. i]
		local _popupTitle = thisEvent["popupTitle" .. i]

		if _option then
			options[#options + 1] = _option
			actions[#actions + 1] = _action
			result[#result + 1] = _result
			popupTitle[#popupTitle + 1] = _popupTitle

		end
	end

	-- Luodaan joku tietty tapahtuma, joka löytyy vain koodista, ja luodaan sille näkymä.
	-- else


	-- 	if sceneParams.type == "sauna" then
	-- 		-- Saunassa pelaaja voisi healata itseään tai kasvataa max hp:ta X määrän

	-- 		title = "sauna"
	-- 		description = "You can feel the overwhelming feeling of relaxation and calmness"

	-- 		options[1] = "Heal for +50 sisu"
	-- 		actions[1] = "print('Heal')"
	-- 		result[1] = "You healed for 50 sisu!"
	-- 		popupTitle[1] = "Getting better"

	-- 		options[2] = "Increase max sisu"
	-- 		actions[2] = "$sisuMax = $sisuMax + 50 "
	-- 		result[2] = "Your max sisu has increased!"
	-- 		popupTitle[2] = "Growing stronger"


	-- 	elseif sceneParams.type == "treasure" then
	-- 		-- Trasure lisää kortteja tai rahaa
	-- 		title = "treasure"
	-- 		description = "You found a chest and are curious of what may you find from inside"

	-- 		options[1] = "Choose to take money"
	-- 		actions[1] = "$money = $money + 10 "
	-- 		result[1] = "You got +10 money!"
	-- 		popupTitle[1] = "Wealthy"

	--
	-- 		options[2] = "Choose to take a new card"
	-- 		actions[2] = "print('Got a Card') "
	-- 		result[2] = "You got a new card!"
	-- 		popupTitle[2] = "Collector"




	-- 		-- 	title = "shop"
	-- 		-- 	description = "You have entered a shop "
	-- 			-- print(sceneParams.isStore)


	-- 	else
	-- 		print("ERROR: Invalid scene type", sceneParams.type)
		-- end

	-- end

	local titleOptions =
	{
		text = title,
		x = sceneLayer.x+10,
		y = sceneLayer.y*0.5,
		width = sceneLayer.x*1.63,
		font = native.systemFont,
		fontSize = 40,
		align = "left"
	}

	local descriptionOptions =
	{
		text = description,
		x = sceneLayer.x*1.33,
		y =  sceneLayer.y*0.82,
		width = sceneLayer.x,
		font = native.systemFont,
		fontSize = 25,
		align = "left"

	}


	local titleText = display.newText( titleOptions )
	sceneGroup:insert(titleText)



	local imageWidth, imageHeight
	local imageScale = 0.7


	if title == "sauna" then
		imageWidth, imageHeight = 300*imageScale, 600*imageScale

	else

		imageWidth, imageHeight = 300, 600

	end


	local layerImage = display.newImageRect( sceneGroup, "Resources/Images/Levels/" .. image,  imageWidth, imageHeight )

	--Tarkistetaan onko eventillä omaa kuvatiedostoa ja sen puuttuessa ladataan oletus
	if not layerImage then
		layerImage = display.newImageRect( sceneGroup, "Resources/Images/Levels/randomEvent.png", imageWidth, imageHeight )
	end

	layerImage.x, layerImage.y = imageBorder.x, imageBorder.y

	local infoText = display.newText( descriptionOptions )
	sceneGroup:insert( infoText )


	for i = 1, #options do
		local data = options[i]
		local text = display.newText( sceneGroup, options[i], screen.centerX-70, screen.centerY+(i*60), native.systemFont, 30 )
		text.id = options[i]
		text.action = actions[i]
		text.result = result[i]
		text.popupTitle = popupTitle[i]
		text.eventType = eventType

		text.background = display.newRect( sceneGroup, text.x*1.39, text.y, 350, 35 )
		text.background.alpha = 0.4
		text.background:setFillColor(0.1)
		text:toFront()
		text:addEventListener("touch", chooseOption)

	end


	--------------------------------------------------------

	-- TODO: TÄMÄ ON TESTAUS ALUE!
	-- print(type(userdata.player.sisuMax))
	-- userdata.player.sisuMax = 300
	-- userdata.player.sisuCurrent = 100

	-- print(userdata.player.sisuMax)
	-- print(userdata.player.sisuCurrent)

	-- if userdata.player.sisuMax > userdata.player.sisuCurrent then
	-- 	if userdata.player.sisuCurrent < userdata.player.sisuMax - 50 then
	-- 	  userdata.player.sisuCurrent = userdata.player.sisuCurrent + 50
	-- 	else
	-- 	  userdata.player.sisuCurrent = userdata.player.sisuCurrent + (userdata.player.sisuMax - userdata.player.sisuCurrent)
	-- 	end
	--   end



	--   print(userdata.player.sisuCurrent)
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
