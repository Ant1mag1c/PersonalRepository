local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local mapData = require("Data.mapData")
local settings = require("Scripts.settings")
local screen = require("Scripts.screen")
local widget = require( "widget" )
local userdata = require("Scripts.userdata")
local playerStatusBar = require("Widgets.playerStatusBar")

local dataHandler = require("Scripts.dataHandler")

-- -----------------------------------------------------------------------------------

local buttonOptions
local sceneParams

local blockTouch = false

local function victory( enemyType )
	if not blockTouch then
		blockTouch = true

		local isBoss = enemyType == "bossNode"

		if userdata.player.currentMap == #mapData and isBoss then
			-- TODO: Luo victory scene.
			-- TODO: poista/nollaa pelaajan userdata victory screenissä.

			composer.gotoScene( "scenes.victory", {
				effect = "fade",
				time = 250,
			})

		else
			local options = {
				effect = "fade",
				time = 250,
				params = {
					-- Jos taistelu on bossin kanssa, niin karttaa ei ladata uudelleen,
					-- vaan siirrytään seuraavaan karttaan.
					continue = enemyType ~= "bossNode",
					newMap = isBoss,
					path = sceneParams.path,
					row = sceneParams.row,
					level = sceneParams.level,
				}
			}

			composer.gotoScene( "scenes.map", options )
		end
	end
end

local function gameover()
	if not blockTouch then
		blockTouch = true
		-- TODO: poista/nollaa pelaajan userdata gameover screenissä.

		composer.gotoScene( "scenes.gameover", {
			effect = "fade",
			time = 250,
		})
	end
end

local function handleButtonEvent( event )
	if ( "ended" == event.phase and not blockTouch ) then
		blockTouch = true

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
	local eventEnemy = sceneParams.eventEnemy

	-- print( "Enemy from event:", eventEnemy )

		if enemyType == "enemy" or enemyType == "elite" then
			if enemyType == "enemy" then
				enemyData = dataHandler.getData( "enemies.tsv" )
			else
				enemyData = dataHandler.getData( "elites.tsv" )
			end
			bgImage = "Resources/Images/Battle/enemy" .. math.random(1, 5) .. ".png"

		elseif enemyType == "bossNode" then
			enemyData = dataHandler.getData( "bosses.tsv" )
			bgImage = "Resources/Images/Battle/boss.png"

		end

	local chosenEnemy

	-- TODO: väliaikainen ratkaisu, jolla pyritään varmistamaan, että pelaaja saa vastaansa halutun tasoisen vihollisen.
	if not eventEnemy then
		local iterations = 1000
		local currentMap = userdata.player.currentMap or 1
		for _ = 1, iterations do
			chosenEnemy = table.getRandom(enemyData)
			if chosenEnemy.firstMap <= currentMap and chosenEnemy.lastMap >= currentMap then
				break
			end
		end

	else
		chosenEnemy = eventEnemy
	end

	-- print("chosen Enemy: ", chosenEnemy, chosenEnemy.name)

	local background = display.newImage( sceneGroup, bgImage )
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	-- TODO: Bossien kanssa taistellaan vain yhtä vihollista vastaan (bossia), mutta muiden kohdalla
	-- vihollisia voi olla useampi (samaa tyyppiä olevaa vihollista).

	-- Luodaan viholliset, pelaajan hahmot ja kortit.
	local cardScript = require("Scripts.Card")
	local enemyScript = require("Scripts.Enemy")

	--creating a button to deal the cards
	local dealButton = display.newRect( sceneGroup, 50, 250, 50 , 50)
	dealButton:addEventListener("touch", cardScript.dealCards)
	dealButton:setFillColor( 0.25, 1, 0.5 )
	cardScript.dealCards(event)

	-------------------------------------------------------

	-- Luodaan pelaajan hahmo.
	local playerScale = 0.5

	local player = display.newImage( sceneGroup, "Resources/Images/Characters/" .. userdata.player.imageBattle, screen.centerX - 300, screen.centerY + 40 )
	player:addEventListener("touch", cardScript.playCard)
	player:scale( playerScale, playerScale )
	player.type = "player"

	-------------------------------------------------------

	local enemy = enemyScript.newEnemy( sceneGroup, screen.centerX + 250, screen.centerY + 80, chosenEnemy )

	-------------------------------------------------------


	-- local card = cardScript.newDeck( userdata.player.cards, sceneGroup, screen.centerX - 300, screen.centerY - 100, player )
	local card = {}

	for i = 1, #userdata.player.cards do
		card[#card+1] = cardScript.newCard( userdata.player.cards[i], sceneGroup )
	end

	-------------------------------------------------------

	local buttonWidth = 120
	local buttonHeight = 373/1072*buttonWidth

	buttonOptions = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "Options",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = handleButtonEvent,
		font = settings.userdata.font,
		fontSize = 22,
	})
	sceneGroup:insert( buttonOptions )

	if system.getInfo( "environment" ) == "simulator" then
		local buttonSkip = widget.newButton({
			left = screen.minX + 2,
			top = screen.maxY - buttonHeight - 2,
			width = buttonWidth,
			height = buttonHeight,
			defaultFile = "Resources/Images/generalbutton1.png",
			overFile = "Resources/Images/generalbutton.png",
			label = "SKIP",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onRelease = function()
				victory( enemyType )
			end,
			font = settings.userdata.font,
			fontSize = 22,
		})
		sceneGroup:insert( buttonSkip )
	end
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		playerStatusBar.create( sceneGroup, buttonOptions )
		buttonOptions:toFront()
		blockTouch = false

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		playerStatusBar.destroy()

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