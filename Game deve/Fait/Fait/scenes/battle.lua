local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require("Scripts.screen")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "Data/cards.tsv" )

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


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view
	sceneParams = event.params or {}
	-- Code here runs when the scene is first created but has not yet appeared on screen

	table.print( sceneParams )

	local enemyType = sceneParams.type
	print( "Luodaan taistelu:", enemyType )

	-- Ladataan vihollistaulukko sen mukaan, mitä vihollista vastaan taistellaan.
	local enemyData
	if enemyType == "enemy" then
		enemyData = dataHandler.getData( "Data/enemies.tsv" )
	elseif enemyType == "elite" then
		enemyData = dataHandler.getData( "Data/elites.tsv" )
	elseif enemyType == "bossNode" then
		enemyData = dataHandler.getData( "Data/bosses.tsv" )
	end

	-- TODO: Bossien kanssa taistellaan vain yhtä vihollista vastaan (bossia), mutta muiden kohdalla
	-- vihollisia voi olla useampi (samaa tyyppiä olevaa vihollista).

	-- Luodaan viholliset, pelaajan hahmot ja kortit.
	local cardScript = require("Scripts.Card")
	local enemyScript = require("Scripts.Enemy")
	local card = {}
	local player = {}
	
	card[1] = cardScript.newCard( "testCard1", sceneGroup)
	card[2] = cardScript.newCard( "testCard2", sceneGroup)
	card[3] = cardScript.newCard( "testCard3", sceneGroup)
	card[4] = cardScript.newCard( "testCard4", sceneGroup)
	card[5] = cardScript.newCard( "testCard5", sceneGroup)
	
	--creating a button to deal the cards
	local dealButton = display.newRect( 50, 250, 50 , 50)
	dealButton:addEventListener("touch", cardScript.dealCards)
	cardScript.dealCards(event)
	
	
	player = display.newRect( 150, 250, 50 , 50)
	player:setFillColor(0,1,0)
	player.type = "player"
	
	player:addEventListener("touch", cardScript.playCard)
	
	enemyScript.newEnemy()
	
	-------------------------------------------------------

	-- Debuggaus nappula, jota käyttämällä voidaan palata karttaan.
	local debugButton = display.newText( sceneGroup, "Return to map", screen.minX + 10, screen.minY + 10, native.systemFont, 24 )
	debugButton.anchorX, debugButton.anchorY = 0, 0
	debugButton:setFillColor( 1, 0.9, 0 )

	debugButton:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			victory( enemyType )
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