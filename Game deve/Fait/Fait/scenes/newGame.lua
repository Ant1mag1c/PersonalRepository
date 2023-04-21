local composer = require( "composer" )
local scene = composer.newScene()

local screen = require("Scripts.screen")

-- hahmoon liittyvät asiat muuttuvat kun pelaaja painaa previous tai next nappulaa
local currentCharacter = 1

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------





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

	-- luo nappuloiden ulkomuoto
	local buttonWidth = 150
	local buttonLenght = 100
	local buttonPadding = 10


	-- luodaan nappulat "back" vasempaan yläkulmaan, "next character" keskelle oikealle, "previous character" keskelle vasemmalle ja "start game" alas oikealle
	local buttonData = {
		{ text="Back", id="back", x=screenW * 0.1, y=screenH * 0.1, },
		{ text="Next character", id="nextCharacter", x=screenW * 0.9, y=screenH * 0.5, },
		{ text="Previous character", id="previousCharacter", x=screenW * 0.1, y=screenH * 0.5, },
		{ text="Start game", id="startGame", x=screenW * 0.9, y=screenH * 0.9, },
	}



	-- luodaan valittavien pelihahmojen lista, joka sisältää hahmon nimen, hahmon kuvan, hahmon kortit, ja hahmon kuvauksen
	local characterList = {
		{ name="Puukkojunkkari", image="Resources/Images/Characters/Puukkojunkkari.png", cards="korttilista1", description="Puukkojunkkarin description" },
		{ name="Metsästäjä", image="Resources/Images/Characters/Metsästäjä.png", cards="korttilista2", description="Metsästäjän description" },
		{ name="Tietäjä", image="Resources/Images/Characters/Tietäjä.png", cards="korttilista3", description="Tietäjän description" },
		{ name="Seppä", image="Resources/Images/Characters/Seppä.png", cards="korttilista4", description="Sepän description" },
	}

	-- luodaan hahmon nimi, kuva, kortit ja kuvaus
	local characterName = display.newText(sceneGroup, characterList[currentCharacter].name, screenW * 0.5, screenH * 0.1, native.systemFontBold, 28)
	characterName:setFillColor( 0 )

	local characterImage = display.newImageRect(sceneGroup, characterList[currentCharacter].image, 200, 200)
	characterImage.x = screenW * 0.5
	characterImage.y = screenH * 0.3

	local characterCards = display.newText(sceneGroup, characterList[currentCharacter].cards, screenW * 0.5, screenH * 0.5, native.systemFontBold, 28)
	characterCards:setFillColor( 0 )

	local characterDescription = display.newText(sceneGroup, characterList[currentCharacter].description, screenW * 0.5, screenH * 0.7, native.systemFontBold, 28)
	characterDescription:setFillColor( 0 )

	-- luodaan hahmon nimen, kuvan, korttien ja kuvauksen päivitys funktio
	local function updateCharacter()
		characterName.text = characterList[currentCharacter].name
		characterImage = display.newImageRect(sceneGroup, characterList[currentCharacter].image, 200, 200)
		characterImage.x = screenW * 0.5
		characterImage.y = screenH * 0.3
		characterCards.text = characterList[currentCharacter].cards
		characterDescription.text = characterList[currentCharacter].description
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
		if event.phase == "began" then
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
				-- TODO: aseta valittu hahmo userdataan.

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

	-- luodaan nappuloiden ulkomuoto, event listener ja teksti sisälle
	for i = 1, #buttonData do
		local button = display.newRect(sceneGroup, buttonData[i].x, buttonData[i].y, 250, 60)
		button.id = buttonData[i].id
		button:setFillColor(0.2, 0, 0)
		button:addEventListener("touch", onButtonEvent)
		local buttonText = display.newText(sceneGroup, buttonData[i].text, buttonData[i].x, buttonData[i].y, native.systemFontBold, 28)
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