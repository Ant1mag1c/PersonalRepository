local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require("Scripts.screen")
local widget = require( "widget" )
local userdata = require("Scripts.userdata")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )

-- -----------------------------------------------------------------------------------

local sceneParams

local function victory( enemyType )

	local options = {
		effect = "fade",
		time = 250,
		params = {
			-- Jos taistelu on bossin kanssa, niin karttaa ei ladata uudelleen,
			-- vaan siirrytään seuraavaan karttaan.
			continue = enemyType ~= "bossNode",
			newMap = enemyType == "bossNode",
			path = sceneParams.path,
			row = sceneParams.row,
			level = sceneParams.level,
		}
	}

	composer.gotoScene( "scenes.map", options )
end


local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then

		composer.showOverlay("scenes.options", {
			isModal = true,
			effect = "fade",
			time = 250,
			params = {
				fromGame = true,
			},
		})
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	sceneParams = event.params or {}
	-- Code here runs when the scene is first created but has not yet appeared on screen


	if not userdata.player then
		userdata.new()
	end


	-- table.print( sceneParams )

	local enemyType = sceneParams.type or "enemy"
	print( "Luodaan taistelu:", enemyType )

	local bgImage

	-- Ladataan vihollistaulukko sen mukaan, mitä vihollista vastaan taistellaan.
	local enemyData
	if enemyType == "enemy" then
		enemyData = dataHandler.getData( "enemies.tsv" )
		bgImage = "Resources/Images/Battle/enemy" .. math.random(1, 5) .. ".png"
	elseif enemyType == "elite" then
		enemyData = dataHandler.getData( "elites.tsv" )
	elseif enemyType == "bossNode" then
		enemyData = dataHandler.getData( "bosses.tsv" )
	end

	local background = display.newImage(sceneGroup, bgImage or "Resources/Images/Battle/boss.png")
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	-- TODO: Bossien kanssa taistellaan vain yhtä vihollista vastaan (bossia), mutta muiden kohdalla
	-- vihollisia voi olla useampi (samaa tyyppiä olevaa vihollista).

	-- Luodaan viholliset, pelaajan hahmot ja kortit.
	local cardScript = require("Scripts.Card")
	local enemyScript = require("Scripts.Enemy")
	local card = {}
	local player = {}

	--creating a button to deal the cards
	local dealButton = display.newRect( sceneGroup, 50, 250, 50 , 50)
	dealButton:addEventListener("touch", cardScript.dealCards)
	dealButton:setFillColor( 0.25, 1, 0.5 )
	cardScript.dealCards(event)

	-------------------------------------------------------

	-- Luodaan pelaajan hahmo.
	local playerScale = 0.5
	-- TODO: korvaa nämä playerCharacters.tsv:hen laitettavilla arvoilla.
	local img = "battle" .. userdata.player.playerClass:sub(1,1):upper(1,1) .. userdata.player.playerClass:sub(2):lower() .. ".png"

	player = display.newImage( sceneGroup, "Resources/Images/Characters/" .. img, screen.centerX - 300, screen.centerY + 40 )
	player:addEventListener("touch", cardScript.playCard)
	player:scale( playerScale, playerScale )
	player.type = "player"

	-------------------------------------------------------

	local enemy = enemyScript.newEnemy( sceneGroup, screen.centerX + 250, screen.centerY + 80, enemyData )

	-------------------------------------------------------

	card[1] = cardScript.newCard( "testCard1", sceneGroup)
	card[2] = cardScript.newCard( "testCard2", sceneGroup)
	card[3] = cardScript.newCard( "testCard3", sceneGroup)
	card[4] = cardScript.newCard( "testCard4", sceneGroup)
	card[5] = cardScript.newCard( "testCard5", sceneGroup)

	-------------------------------------------------------

	local buttonWidth = 120
	local buttonHeight = 373/1072*buttonWidth

	local buttonOptions = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "Options",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = handleButtonEvent
	})
	sceneGroup:insert( buttonOptions )
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
		composer.removeScene( "scenes.battle" )
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