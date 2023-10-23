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
local cardScript = require("Scripts.Card")
local playerScript = require("Scripts.Player")
local enemyScript = require("Scripts.Enemy")

-- -----------------------------------------------------------------------------------

local groupLevel = display.newGroup()
local groupCards = display.newGroup()
local groupUI = display.newGroup()

local turnStart, turnEnd, turnEnemy

local currentMap
local buttonOptions
local buttonEnd
local sceneParams
local enemyType

local whoseTurn = ""
local enemy = {}
local player

local blockTouch = false

-- Joidenkin erikoiskorttien kanssa voi tarvita tietoa muista korteista, tai miten
-- kyseistä erikoiskorttia on pelattu. Tämä tieto tallennetaan tähän taulukkoon.
local specialCardData = {
	["luentoStacks"] = 1,
}

-- -----------------------------------------------------------------------------------

local function victory()
	if not blockTouch then
		blockTouch = true

		local isBoss = enemyType == "bossNode"

		if currentMap == #mapData and isBoss then
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

		composer.gotoScene( "scenes.gameover", {
			effect = "fade",
			time = 250,
		})
	end
end


local function applyCardEffect( target, activeCard )
	local cardData = activeCard.data
	----------------------------------
	-- Debug prints:
	----------------------------------
	-- print( "activeCard:" )
	-- for k, v in pairs( cardData ) do
	-- 	print( "   ", k, v )
	-- end

	-- print( "\ntarget:" )
	-- for k, v in pairs( target ) do
	-- 	print( "   ", k, v )
	-- end
	----------------------------------


	-- Pelaajan statsit, joita voi helposti muuttaa, ovat:
		-- sisu
		-- energy (eli temp energy)
		-- attack
		-- defense
		-- money

	-- Vihollisten statsit:
		-- hp
		-- minAttack
		-- maxAttack
		-- defense

	-- Korttien "statsit":
		-- energy (eli paljonko energiaa maksaa pelata kyseinen kortti)
		-- intensity (eli paljonko kortti tekee damagea, healaa, buffaa tai debuffaa statseja)
		-- duration (eli monenko vuoron ajan se kortti tekee jotain)

	-- Korttien tyypit: heal, damage, buff, debuff, special.
		-- special kortteja ei voi buffata muilla korteilla.


	----------------------------------


    -- -- Hahmokohtaisia ja devaajan muokattavissa olevia statseja
    -- userdata.player.defense = tonumber( params.defense or userdata.player.defense )
    -- userdata.player.energy = tonumber( params.energy or userdata.player.energy )
    -- userdata.player.sisuMax = tonumber( params.sisu or userdata.player.sisu )
    -- userdata.player.startingCards = tonumber( params.startingCards or userdata.player.startingCards )
    -- userdata.player.attack = tonumber( params.attack or userdata.player.attack )
    -- userdata.player.bleedCount = userdata.bleedCount or 0
    -- userdata.player.moveReductionCount = 0
    -- userdata.player.quaranteedEvents = userdata.quaranteedEvents or {}
    -- userdata.player.goodEventCount = 0

    -- -- Luodaa muita default / aloitus statseja
    -- userdata.player.sisuCurrent = tonumber( userdata.player.sisuMax )
    -- userdata.player.money = tonumber( defaultStats.money )


	----------------------------------


	-- newEnemy.name = enemyData.name
	-- newEnemy.alignment = enemyData.alignment
	-- newEnemy.hp = math.random( enemyData.minHP, enemyData.maxHP ) or 10
	-- newEnemy.minAttack = enemyData.minAttack or enemyData.maxAttack or 1
	-- newEnemy.maxAttack = enemyData.maxAttack or enemyData.minAttack or 1
	-- newEnemy.defense = enemyData.defense or 0


	----------------------------------

	-- TODO: lisää userdata.player.bleed / bleedCount / moveReductionCount / quaranteedEvents / goodEventCount
	-- Tuo ne battle sceneen ja lisää ne playerStatusBariin omana visuaalisena elementtinä.
	-- Pelaajan tulee ottaa vahinkoa battlessä myös map scenen bleedistä.

	-- Vähennä pelaajan energiasta kortin "energia hinta" ja ylimenevä osa sisusta.
	local energyLeft = userdata.player.energy - cardData.energy
	userdata.player.energy = math.max( energyLeft, 0 )
	if userdata.player.energy < 0 then
		userdata.player.sisuCurrent = math.max( userdata.player.sisuCurrent + energyLeft, 0 )
	end
	playerStatusBar.update()

	-- Erikoiskorteilla on korttikohtaiset efektit.
	if cardData.effect == "special" then



	-- Muilla korteilla on statusEfekti funktiot, jotka liitetään kortin kohteeseen.
	else
		-- TODO: luo loopissa target taulukko ja laita "enemyAll" kohteet sinne, "card" ja "player" ovat vain 1 indeksin taulukoita.


		local statusEffect = {
			duration = cardData.duration,
			effect = cardData.effect,
			intensity = cardData.intensity,
			target = target,
		}

		function statusEffect:update()
			self.duration = self.duration - 1

			-- Päivitä kohteen statseja.
			local _target = self.target.type == "card" and self.target.data or self.target
			if not _target[self.effect] then
				print( "ERROR: kohteella \"" .. _target.type .. "\" ei ole arvoa:\"" .. self.effect .. "\"" )
				activeCard.front:setFillColor( 1, 0, 0 )
				activeCard.back:setFillColor( 1, 0, 0 )
				cardScript.canPlay = true
				return
			end
			-- Lisätään pelaajan attack korttiin, jos se pelataan viholliseen ja on damage kortti.
			_target[self.effect] = _target[self.effect] + self.intensity + ((_target.type == "enemy" or _target.type == "enemyAll") and userdata.player.attack or 0)

			-- Animoi kortin kohdetta.
			if target.type == "card" then
				transition.to( target, {
					time = 250,
					xScale = target.startScale*1.25,
					yScale = target.startScale*1.25,
					transition = easing.continuousLoop,
					onComplete=function()
						-- card:update()
						cardScript.canPlay = true
					end
				} )

			elseif target.type == "player" then
				transition.to( target, {
					time = 250,
					xScale = target.startScale*1.25,
					yScale = target.startScale*1.25,
					transition = easing.continuousLoop,
					onComplete=function()
						playerStatusBar.update()
						cardScript.canPlay = true
					end
				} )

			elseif target.type == "enemy" then
				transition.to( player, {
					delay = 50,
					time = 250,
					x = player.x + 50,
					transition = easing.inOutBack,
					onComplete = function()
						transition.to( target, { time=250, x=target.x + 20, yScale=0.85, transition=easing.continuousLoop } )
						transition.to( player, {
							time = 250,
							x = player.x - 50,
							transition = easing.outCubic,
							onComplete=function()
								target:updateStatus()
								cardScript.canPlay = true
							end
						})
					end,
				})
			end

			if self.duration <= 0 then
				return true
			end
		end
		statusEffect:update()

		if statusEffect.duration > 0 then
			target:addStatusEffect( statusEffect )
		end

	end
end


function turnEnemy()
	-- print( "enemy turn starts" )

	local delay = 500
	local attackTime = 250
	local recoveryTime = 250

	local survivingEnemies = 0
	for i = 1, #enemy do
		if not enemy[i].isDead then
			survivingEnemies = survivingEnemies + 1
		end
	end

	if survivingEnemies == 0 then
		victory()

	else
		local enemyIndex = 1

		timer.performWithDelay( delay+attackTime+recoveryTime+50, function( event )

			-- Hae ensimmäinen elossa oleva vihollinen.
			local target
			for i = enemyIndex, #enemy do
				if not enemy[i].isDead then
					target = enemy[i]
					enemyIndex = i + 1
					break
				end
			end

			-- Vihollinen hyökkää pelaaajaan.
			local damage = math.random( target.minAttack, target.maxAttack ) - userdata.player.defense
			if damage > 0 then
				-- Pelaaja menettää ensiksi energiaa ja ylimenevä osa sisusta.
				local energyLeft = userdata.player.energy - damage
				userdata.player.energy = math.max( energyLeft, 0 )
				if energyLeft < 0 then
					userdata.player.sisuCurrent = math.max( userdata.player.sisuCurrent + energyLeft, 0 )
				end
			end

			-- Animoi vihollisen hyökkäys ja pelaajan vahinko.
			transition.to( target, {
				time = attackTime,
				x = target.x - 50,
				transition = easing.inOutBack,
				onComplete = function()
					playerStatusBar.update()

					transition.to( player, { time=250, x=player.x - 20, yScale=player.startScale*0.85, transition=easing.continuousLoop } )
					transition.to( target, {
						time = recoveryTime,
						x = target.x + 50,
						transition = easing.outCubic,
						onComplete = function()
							if enemyIndex > #enemy then
								turnStart()
							end
						end
					})
				end,
			})

		end, survivingEnemies )
	end
end


function turnStart()
	-- print( "player turn starts" )
	whoseTurn = "player"

	if player.isDead then
		gameover()
	else
		-- Pelaaja voi saada joka vuoro vain tietyn verran kortteja, jos niitä on pakassa tarjolla ja tämän käsi ei ole "täysi".
		local cardsToDeal = math.min( userdata.player.cardPerTurn, #cardScript.deck, userdata.player.maxCardsHand - #cardScript.hand )
		local delay = 350

		if cardsToDeal > 0 then
			cardScript.canPlay = false

			timer.performWithDelay( delay, function()
				cardScript.dealCard()
			end, cardsToDeal )

			timer.performWithDelay( delay*cardsToDeal+20, function()
				player:updateStatus()
				buttonEnd.alpha = 1
				buttonEnd:setEnabled( true )
				cardScript.canPlay = true

				if player.isDead then
					gameover()
				end
			end )
		else
			player:updateStatus()
			buttonEnd.alpha = 1
			buttonEnd:setEnabled( true )
			cardScript.canPlay = true

			if player.isDead then
				gameover()
			end
		end
	end
end

-- Vuoro loppuu jos pelaaja painaa nappia, pakka ja kädessä olevat kortit loppuvat,
-- viimeinen vihollinen kuolee, tai pelaaja kuolee.
function turnEnd( event )
	-- Pelaaja voi päättää vuoronsa painamalla nappia, jolloin event on button event-taulukko.
	if type( event ) == "table" and event.phase then
		event = "playerEnded"

		if whoseTurn ~= "player" then
			return
		end
	end
	-- print( "player turn ends", event )
	whoseTurn = "enemy"
	buttonEnd.alpha = 0.25
	buttonEnd:setEnabled( false )

	if event == "victory" then
		victory()

	elseif event == "gameover" then
		gameover()

	elseif event == "playerEnded" or event == "outOfCards" then
		if event == "outOfCards" then
			-- pelaajan tulee ottaa damagea aina kun pakka sekoitetaan uudestaan.
		end
		turnEnemy()

	end

	return true
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

	-- Jos devaaja hyppää suoraan tähän sceneen niin userdataa ei ole vielä luotu.
	if not userdata.player then
		userdata.new()
	end

	currentMap = userdata.player.currentMap or sceneParams.currentMap or 1
	enemyType = sceneParams.type or "enemy"
	print( "Luodaan taistelu:", enemyType )

	-- for k, v in pairs( sceneParams ) do
	-- 	print( k, v )
	-- end

	local bgImage

	-- Ladataan vihollistaulukko sen mukaan, mitä vihollista vastaan taistellaan.
	local eventEnemy = sceneParams.eventEnemy
	local enemyCount = sceneParams.enemyCount or nil
	local enemyRandom = math.random()
	local enemyData

	print("a", enemyCount)

	-- print( "Enemy from event:", eventEnemy )

	if enemyType == "enemy" or enemyType == "elite" then
		if enemyType == "enemy" then
			enemyData = dataHandler.getData( "enemies.tsv" )
			-- Jos vihollismäärää ei ole vielä määritetty niin ajetaan seuraava lohko
			if not enemyCount then
				-- Heikoimpia vihollisia voi olla useita (voitettavissa).
				if enemyRandom < 0.6 then
					enemyCount = 1
				elseif enemyRandom < 0.9 then
					enemyCount = 2
				elseif enemyRandom < 0.97 then
					enemyCount = 3
				else
					enemyCount = 4
				end
			end
		else
			enemyData = dataHandler.getData( "elites.tsv" )

			-- Eliitti vihollisia ei kannata laittaa useita (vaikea voittaa).
			if enemyRandom < 0.75 then
				enemyCount = 1
			else
				enemyCount = 2
			end
		end
		bgImage = "Resources/Images/Battle/enemy" .. math.random(1, 5) .. ".png"

	elseif enemyType == "bossNode" then
		enemyData = dataHandler.getData( "bosses.tsv" )
		bgImage = "Resources/Images/Battle/boss.png"
		enemyCount = 1

	end

	-------------------------------------------------------

	local background = display.newImage( groupLevel, bgImage )
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

	-------------------------------------------------------

	local chosenEnemy = {}

	-- event kohtaisissa taisteluissa vihollinen on jo valittu, eikä sitä tarvitse arpoa.
	if not eventEnemy then
		-- Luodaan väliaikainen taulukko, joka voidaan sekoittaa ja josta valitaan vihollisia.
		local t = {}
		for _, v in pairs( enemyData ) do
			t[#t+1] = v
		end

		for i = 1, enemyCount do
			-- Sekoittamisella varmistetaan, että viholliset eivät ole aina samassa järjestyksessä
			-- ja että jos vihollisia on useita, niin ne eivät ole aina samoja.
			table.shuffle( t )

			for enemyIndex = 1, #t do
				if t[enemyIndex].firstMap <= currentMap and t[enemyIndex].lastMap >= currentMap then
					chosenEnemy[i] = t[enemyIndex]
					break
				end
			end
		end
	else
		for i = 1, enemyCount do
			chosenEnemy[i] = eventEnemy
		end
	end

	local xEnemy = screen.centerX + 200
	local yEnemy = screen.centerY - 120

	for i = 1, enemyCount do
		if i > 1 then
			xEnemy = enemy[i-1].x + enemy[i-1].width*0.35
			yEnemy = enemy[i-1].y + enemy[i-1].height*0.5
		end
		enemy[i] = enemyScript.newEnemy( groupLevel, xEnemy, yEnemy, chosenEnemy[i] )

		transition.to( enemy[i], {
			time=1250,
			tag="battle",
			x=enemy[i].xStart + math.random(-5,5),
			xScale=math.random(95,105)*0.01,
			yScale=math.random(95,105)*0.01,
			transition=easing.continuousLoop,
			iterations=-1
		})
	end

	-------------------------------------------------------

	player = playerScript.newPlayer( groupLevel, screen.centerX - 300, screen.centerY + 40 )

	transition.to( player, {
		time=1750,
		tag="battle",
		x=player.xStart + math.random(-3,3),
		xScale=player.startScale + math.random(-1,1)*0.01,
		yScale=player.startScale + math.random(-1,1)*0.01,
		transition=easing.continuousLoop,
		iterations=-1
	})

	-------------------------------------------------------

	-- params.noShuffle
	-- params.isGameDeck
	-- params.cardRevealed

	-- params = {
	-- 	noShuffle = true, -- Kauppa/deck scenessä ei shuffleta.
	-- 	isGameDeck = true,
	-- 	cardRevealed = true, Kauppa/deck scenessä kortit näkyvät heti
	-- 	x = 0,
	-- 	y = 0,
	-- 	xScale = 0.5,
	-- 	yScale = 0.5,
	-- 	rotation = 0,
	-- }

	cardScript.newDeck( groupCards, turnEnd, applyCardEffect, { isGameDeck=true } )

	-------------------------------------------------------

	-- Luodaan UI napit.

	local buttonWidth = 120
	local buttonHeight = 373/1072*buttonWidth

	buttonEnd = widget.newButton({
		left = screen.maxX - buttonWidth - 12,
		top = screen.maxY - buttonHeight - 12,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "End Turn",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onRelease = turnEnd,
		font = settings.userdata.font,
		fontSize = 22,
	})
	groupUI:insert( buttonEnd )

	buttonOptions = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "Options",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onRelease = handleButtonEvent,
		font = settings.userdata.font,
		fontSize = 22,
	})
	groupUI:insert( buttonOptions )

	if system.getInfo( "environment" ) == "simulator" then
		local buttonSkip = widget.newButton({
			left = screen.maxX + 2 - buttonWidth - 2,
			top = screen.minY + buttonHeight + 4,
			width = buttonWidth,
			height = buttonHeight,
			defaultFile = "Resources/Images/generalbutton1.png",
			overFile = "Resources/Images/generalbutton.png",
			label = "DEV SKIP",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onRelease = function()
				victory()
			end,
			font = settings.userdata.font,
			fontSize = 22,
		})
		groupUI:insert( buttonSkip )
	end

	sceneGroup:insert( groupLevel )
	sceneGroup:insert( groupCards )
	sceneGroup:insert( groupUI )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		playerStatusBar.create( groupUI, buttonOptions )
		buttonOptions:toFront()
		blockTouch = false

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		turnStart()

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