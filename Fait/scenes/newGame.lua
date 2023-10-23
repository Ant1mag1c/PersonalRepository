local composer = require( "composer" )
local scene = composer.newScene()

local settings = require("Scripts.settings")
local screen = require("Scripts.screen")
local widget = require("widget")

local dataHandler = require("Scripts.dataHandler")
local characterData = dataHandler.getData( "playerCharacters.tsv" )

-- hahmoon liittyvät asiat muuttuvat kun pelaaja painaa previous tai next nappulaa
local currentCharacter = 1
local currentCharacterID

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local onMouseEvent
local showLogoInfo




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen


	local background = display.newImage(sceneGroup, "Resources/Images/bgSketch3333.jpg")
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	-- variaabelit joiden avulla saadaan asetettua nappulat riippumatta ruudun koosta
	local screenW = display.contentWidth
	local screenH = display.contentHeight
	local mouseX = 0
	local mouseY = 0



	-- VANHA:
	-- luodaan valittavien pelihahmojen lista, joka sisältää hahmon nimen, hahmon kuvan, hahmon kortit, ja hahmon kuvauksen
	-- local characterList = {
	-- 	{ name="Puukkojunkkari", id="puukkojunkkari", image="Resources/Images/Characters/Puukkojunkkari.png", cards="korttilista1", description="Puukkojunkkarin description" },
	-- 	{ name="Metsästäjä", id="metsastaja", image="Resources/Images/Characters/Metsästäjä.png", cards="korttilista2", description="Metsästäjän description" },
	-- 	{ name="Tietäjä", id="tietaja", image="Resources/Images/Characters/Tietäjä.png", cards="korttilista3", description="Tietäjän description" },
	-- 	{ name="Seppä", id="seppa", image="Resources/Images/Characters/Seppä.png", cards="korttilista4", description="Sepän description" },
	-- 	{ name="Kyläjuoppo", id="kylajuoppo", image="Resources/Images/Characters/Tietäjä.png", cards="korttilista5", description="Kyläjuopon description" },
	-- }
	-- currentCharacterID = characterList[currentCharacter].id

	-- UUSI (väliaikainen ratkaisu):
	-- Luetaan hahmot tiedostosta ja prosessoidaan ne automaagisesti vanhan mallin mukaiseen formaattiin.
	local characterList = {}
	for k, v in pairs( characterData ) do
		characterList[#characterList+1] = { name=v.name, id=k, image="Resources/Images/Characters/" .. v.imageAvatar }
	end
	currentCharacterID = characterList[currentCharacter].id

	-- luodaan hahmoikkuna
	local characterFrame = display.newImageRect(sceneGroup, "Resources/Images/menu.png", 424, 569)
	characterFrame.x = display.contentCenterX
	characterFrame.y = display.contentCenterY

	--luodaan tausta hahmon kuvaukselle
	local descriptionFrame = display.newRect(sceneGroup, characterFrame.x, characterFrame.y + 60, 280, 80)
	descriptionFrame:setFillColor(0)
	descriptionFrame.alpha = 0.5

	-- luodaan hahmon nimi, kuva, kortit ja kuvaus
	local characterName = display.newText(sceneGroup, characterList[currentCharacter].name, descriptionFrame.x, characterFrame.y - characterFrame.height*0.5 + 56, settings.userdata.font, 28 )
	characterName:setFillColor( 1,1,1 )

	local characterImage = display.newImageRect(sceneGroup, characterList[currentCharacter].image, 200, 200)
	characterImage.x = characterName.x
	characterImage.y = characterName.y + characterName.height*0.5 + characterImage.height*0.5 + 10

	--local characterCards = display.newText(sceneGroup, characterList[currentCharacter].cards, screenW * 0.5, screenH * 0.5, settings.userdata.font, 28)
	--characterCards:setFillColor( 0 )

	--luodaan hahmon kuvausteksti ja sen tyyli
	local options =
	{
		parent = sceneGroup,
		text = characterData[currentCharacterID].lore,
		x = descriptionFrame.x,
		y = descriptionFrame.y,
		width = descriptionFrame.width - 10,
		-- height = descriptionFrame.height,
		font = settings.userdata.font,
		fontSize = 18,
		align = "center"
	}

	-- Luodaan hahmon statsien kuville oma info tekstinsä
	local infoOptions =
	{
		parent = sceneGroup,
		text = "nil",
		x = descriptionFrame.x,
		y = descriptionFrame.y,
		width = descriptionFrame.width - 10,
		-- height = descriptionFrame.height,
		font = settings.userdata.font,
		fontSize = 18,
		align = "center"
	}

	local characterDescription = display.newText(options)

	function onMouseEvent(event)
		mouseX, mouseY = event.x, event.y
	end


	--luodaan kuvakkeet hahmon ominaisuuksille
	local sisu = display.newImageRect(sceneGroup, "Resources/Images/Icons/sisu.png", 40, 40)
	sisu.x = characterFrame.x - 100
	sisu.y = characterFrame.y + 135

	local attackPower = display.newImageRect(sceneGroup, "Resources/Images/Icons/attack.png", 40, 40)
	attackPower.x =  characterFrame.x
	attackPower.y =  characterFrame.y + 135

	local defencePower = display.newImageRect(sceneGroup, "Resources/Images/Icons/defense.png", 40, 40)
	defencePower.x = characterFrame.x + 100
	defencePower.y = characterFrame.y + 135

	local energy = display.newImageRect(sceneGroup,"Resources/Images/Icons/energy.png", 40, 40)
	energy.x = characterFrame.x - 60
	energy.y = characterFrame.y + 190

	local cards = display.newImageRect(sceneGroup, "Resources/Images/Icons/cards.png", 40, 40)
	cards.x = characterFrame.x + 60
	cards.y = characterFrame.y + 190



	-- TODO: käännä tekstejä englanniksi.
	-- TODO: poista "guaranteed card" ja korvaa se hahmon traitilla.


	local infoTextCreated = false
	local infoText

	-- Luodaan jokaiselle logolle pop-up palkki kun hiiri asetetaan logon päälle
	function showLogoInfo()
		local outOfBounds = true

		-- Luodaan jokaiselle logolle säde jonka sisällä logon info annetaan pelaajalle
		local sisuDistance = math.sqrt( ( (mouseX-sceneGroup.x) - sisu.x )^2 + ( (mouseY+sceneGroup.y) - sisu.y )^2 )
		local attackDistance = math.sqrt( ( (mouseX-sceneGroup.x) - attackPower.x )^2 + ( (mouseY+sceneGroup.y) - attackPower.y )^2 )
		local defenceDistance = math.sqrt( ( (mouseX-sceneGroup.x) - defencePower.x )^2 + ( (mouseY+sceneGroup.y) - defencePower.y )^2 )
		local energyDistance = math.sqrt( ( (mouseX-sceneGroup.x) - energy.x )^2 + ( (mouseY+sceneGroup.y) - energy.y )^2 )
		local cardsDistance = math.sqrt( ( (mouseX-sceneGroup.x) - cards.x )^2 + ( (mouseY+sceneGroup.y) - cards.y )^2 )

		if sisuDistance < 20 then
			infoOptions.text = "Sisu: character's hitpoints. Also used to play cards when energy is exhausted."
			outOfBounds = false
		end

		if attackDistance < 20 then
			infoOptions.text = "Attack: extra damage dealt to opponents."
			outOfBounds = false
		end

		if defenceDistance < 20 then
			infoOptions.text = "Defense: reduce damage taken from opponents."
			outOfBounds = false
		end

		if energyDistance < 20 then
			infoOptions.text = "Energy: amount of energy used to play cards per turn."
			outOfBounds = false
		end

		if cardsDistance < 20 then
			infoOptions.text = "Cards: number of starting cards."
			outOfBounds = false
		end


		if outOfBounds then
			characterDescription.alpha = 1
			display.remove( infoText )
			infoTextCreated = false

		-- Jos kursori on logon päällä
		else
			characterDescription.alpha = 0
			if infoTextCreated == false then
				infoText = display.newText( infoOptions )

				infoTextCreated = true
			end
		end

	end


	--luodaan tekstit kuvaamaan hahmon ominaisuuksien arvoja
	local iconTextPadding = 6

	local sisuValue = display.newText(sceneGroup, characterData[currentCharacterID].sisu, sisu.x + sisu.width*0.5 + iconTextPadding, sisu.y, settings.userdata.font, 23)
	sisuValue.anchorX = 0

	local attackValue = display.newText(sceneGroup, characterData[currentCharacterID].attack, attackPower.x + attackPower.width*0.5 + iconTextPadding, attackPower.y, settings.userdata.font, 23)
	attackValue.anchorX = 0

	local defenseValue = display.newText(sceneGroup, characterData[currentCharacterID].defense, defencePower.x + defencePower.width*0.5 + iconTextPadding, defencePower.y, settings.userdata.font, 23)
	defenseValue.anchorX = 0

	local energyValue = display.newText(sceneGroup, characterData[currentCharacterID].energy, energy.x + energy.width*0.5 + iconTextPadding, energy.y, settings.userdata.font, 23)
	energyValue.anchorX = 0

	local cardsValue = display.newText(sceneGroup, characterData[currentCharacterID].startingCards, cards.x + cards.width*0.5 + iconTextPadding, cards.y, settings.userdata.font, 23)
	cardsValue.anchorX = 0

	local guaranteedCardText = display.newText(sceneGroup,"Guaranteed card: ", characterFrame.x + 44, characterFrame.y + 240, settings.userdata.font, 20)
	guaranteedCardText.anchorX = 1

	local guaranteedCardValue = display.newText(sceneGroup, characterData[currentCharacterID].guaranteedCard, guaranteedCardText.x + 10, guaranteedCardText.y, settings.userdata.font, 20)
	guaranteedCardValue.anchorX = 0


	-- luodaan hahmon nimen, kuvan, korttien ja kuvauksen päivitys funktio
	local function updateCharacter()
		-- Vanha kuva tulee aina tuhota ennen kuin luodaan uusi. Muuten vanha kuva jää näkyviin ja tietokoneen muistiin.
		display.remove(characterImage)

		currentCharacterID = characterList[currentCharacter].id

		characterName.text = characterList[currentCharacter].name
		characterImage = display.newImageRect(sceneGroup, characterList[currentCharacter].image, 200, 200)
		characterImage.x = characterName.x
		characterImage.y = characterName.y + characterName.height*0.5 + characterImage.height*0.5 + 10

		sisuValue.text = characterData[currentCharacterID].sisu
		attackValue.text = characterData[currentCharacterID].attack
		defenseValue.text = characterData[currentCharacterID].defense
		energyValue.text = characterData[currentCharacterID].energy
		cardsValue.text = characterData[currentCharacterID].startingCards
		guaranteedCardValue.text = characterData[currentCharacterID].guaranteedCard
		characterDescription.text = characterData[currentCharacterID].lore
	end

	-- luodaan funktio joka käy listan läpi ja aloittaa alusta jos se on listan viimeinen
	local function nextCharacter()
		if currentCharacter < #characterList then
			currentCharacter = currentCharacter + 1
		else
			currentCharacter = 1
		end
		updateCharacter()
	end

	-- luodaan funktio joka käy listan läpi taaksepäin ja aloittaa lopusta jos se on listan ensimmäinen
	local function previousCharacter()
		if currentCharacter > 1 then
			currentCharacter = currentCharacter - 1
		else
			currentCharacter = #characterList
		end
		updateCharacter()
	end


	-- nappuloiden funktiot
	local function onButtonEvent(event)
		if event.phase == "ended" then
			local target = event.target
			print(target.id)

			-- jos nappulan id on "back" niin palaa takaisin mainMenu sceneen
			if target.id == "back" then
				composer.gotoScene("scenes.mainMenu",{
					time = 250,
					effect = "fade"
				})
			-- jos nappulan id on "nextCharacter" niin vaihda seuraavaan hahmoon
			elseif target.id == "nextCharacter" then
				nextCharacter()
			-- jos nappulan id on "previousCharacter" niin vaihda edelliseen hahmoon
			elseif target.id == "previousCharacter" then
				previousCharacter()
			-- jos nappulan id on "startGame" niin aloita peli
			elseif target.id == "startGame" then
				local userdata = require("Scripts.userdata")
				userdata.new({playerClass=currentCharacterID})

				composer.gotoScene("scenes.map",{
					time = 250,
					effect = "fade",
					params = {
						newGame = true
					}
				})
			end
		end
		return true
	end

	local buttonWidth = 220
	local buttonHeight = 373/1072*buttonWidth

	-- luodaan nappulat "back" vasempaan yläkulmaan, "next character" keskelle oikealle, "previous character" keskelle vasemmalle ja "start game" alas oikealle
	local buttonData = {
		{ text="Back", id="back", width=200, height=458/1141*200, defaultFile="Resources/Images/backbutton1.png", overFile="Resources/Images/backbutton.png", x=screen.minX + 106, y=screen.minY + 50, },
		{ text="Next character", id="nextCharacter", x=screen.maxX - buttonWidth*0.5 - 10, y=screen.centerY },
		{ text="Previous character", id="previousCharacter", x=screen.minX + buttonWidth*0.5 + 10, y=screen.centerY },
		{ text="Start game", id="startGame", x=screen.maxX - buttonWidth*0.5 - 10, y=screen.maxY - buttonHeight*0.5 - 10 },
	}

	-- luodaan nappuloiden ulkomuoto, event listener ja teksti sisälle
	for i = 1, #buttonData do
		local button = widget.newButton({
			width = buttonData[i].width or buttonWidth,
			height = buttonData[i].height or buttonHeight,
			defaultFile = buttonData[i].defaultFile or "Resources/Images/generalbutton1.png",
			overFile = buttonData[i].overFile or "Resources/Images/generalbutton.png",
			id = buttonData[i].id,
			label = buttonData[i].text,
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = onButtonEvent,
			font = settings.userdata.font,
			fontSize = 22,
		})
		button.x, button.y = buttonData[i].x, buttonData[i].y
		sceneGroup:insert( button )
	end
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		Runtime:addEventListener( "mouse", onMouseEvent )
		Runtime:addEventListener( "enterFrame", showLogoInfo )


	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		Runtime:removeEventListener( "mouse", onMouseEvent )
		Runtime:removeEventListener( "enterFrame", showLogoInfo )

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