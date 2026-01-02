-- Ladataan Composer, jotta voimme käyttää sen funktioita.
local composer = require( "composer" )

-- Luodaan uusi scene-objekti.
local scene = composer.newScene()
local screen = require( "scripts.screen" )
local ui = require( "scripts.ui" )
local ponytiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )
local playerModule = require( "scripts.player" )
-- local spikesModule = require( "scripts.spikes" )
-- local trampolineModule = require( "scripts.trampoline" )
local heartModule = require( "scripts.heart" )
-- local coinModule = require( "scripts.coin" )
-- local goalModule = require( "scripts.goal" )
-- local hatModule = require( "scripts.hat" )
local controls = require( "scripts.controls" )
local loadsave = require( "scripts.loadsave" )
local camera = require( "scripts.camera" )
local background, levelGroup, foreground

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 9.8 )
physics.setDrawMode( "hybrid" )  -- Vaihtoehdot: "normal", "debug", "hybrid"

--------------------------------------------------------------------------------------
-- scene event -funktioiden ulkopuolella oleva koodi suoritetaan vain kerran, ellei
-- sceneä poisteta kokonaan omposer.removeScene() avulla. Täällä kannattaa määrittää
-- yleiset muuttujat, jotta ne ovat käytettävissä kaikissa scene-funktioissa.
--------------------------------------------------------------------------------------

local player, counterHP, levelBorder
local sceneGroup

local enemy = {}

local function menuClose()
	display.remove( ui.menuGroup )
	ui.menuGroup = nil
	composer.hideOverlay( 0 )

	physics.start()
	transition.resumeAll()
	timer.resumeAll()
end

local function menuOpen( menuType )
	physics.pause()
	transition.pauseAll()
	timer.pauseAll()

	-- Lisätään viittauksia menun tilaan.
	ui.menuType = menuType
	ui.callback = menuClose

	ui.newMenu( sceneGroup, menuType )
end

local function movePlayer( vx, vy )
	player:move( vx, vy )
end

local function keyPressed( action, phase )
	-- print( "action", action, "phase", phase )

	if action == "jump" then
		player:jump( phase == "down" )

	elseif action == "menu" then
		if phase == "down" then
			if ui.menuGroup then
				if ui.menuType == "pause" then
					menuClose()
				end
			else
				menuOpen( "pause" )
			end
		end
	end
end

local function onCollision( self, event )
	-- print( "collided with", event.other.id, "phase", event.phase )
	local phase = event.phase
	local id = event.other.id

	-- Jos pelaaja on kuollut, ei käsitellä muita törmäyksiä.
	if player.isDead then
		return
	end

	if phase == "began" then
		if event.other.isStairs then
			print( "stairs" )
			player.moveSpeed = 50
		end

		if id == "platform" or id == "rope" then
			player:resetJumpCount()

			if id == "rope" then
				player:touchRope( true )
			end


		elseif id == "heart" or id == "coin" then
			event.other:collect()

			if id == "heart" then
				player:addHP( 1 )
				counterHP:update( player.currentHP )
			end

		elseif id == "goal" then
			event.other:complete()
			player.isDead = true
			controls.stop()
			menuOpen( "complete" )

		elseif id == "spikes" or id == "levelBorder" or event.other.isEnemy then
			local isBorder = (id == "levelBorder")
			local damage = 1
			if isBorder then
				damage = player.maxHP
			end
			player:takeDamage( damage, isBorder )
			counterHP:update( player.currentHP )

			if player.isDead then
				controls.stop()
				menuOpen( "gameover" )
			end
		end

	elseif phase == "ended" then
		if event.other.isStairs then
			player.moveSpeed = 100
		end

		if id == "rope" then
			player:touchRope( false )
		end

	end
end

--------------------------------------------------------------------------------------
-- scene event -funktiot:
--------------------------------------------------------------------------------------

-- create: kutsutaan kun scene luodaan ensimmäistä kertaa,
-- tai jos se on poistettu ja sitä luodaan uudelleen.
function scene:create( event )
	sceneGroup = self.view
	local level = event.params and event.params.level or "tutorial.json"
	ui.currentLevel = level
	print( "Ladataan kenttä: " .. level )


	-- Ladataan kentän data JSON-tiedostosta.
	local mapData = json.decodeFile(system.pathForFile("assets/" .. level, system.ResourceDirectory))
	-- Kerrotaan ponytiled-kirjastolle, mistä kenttä tulee ladata.
	local map = ponytiled.new(mapData, "assets")
	sceneGroup:insert( map )
	map.x = display.contentCenterX - map.designedWidth/2
	map.y = display.contentCenterY - map.designedHeight/2

	background = map:findLayer( "background" )
	levelGroup = map:findLayer( "level" )
	foreground = map:findLayer( "foreground" )

	------------------------------------------------------------------------------
	-- Luodaan dynaamiset hahmot ja objektit:
	player = map.getFirstTile( "id", "player" )
	player = playerModule.new( levelGroup, player )
	player.collision = onCollision
	player:addEventListener( "collision" )

	local stairsTiles = map.getAllTiles("isStairs", true)

for i = 1, #stairsTiles do
	local tile = stairsTiles[i]

	local w = tile.width
	local h = tile.height

	physics.addBody(tile, "static", {
		shape = {
		-- chain = {
			-- bottom-left
			-w * 0.5,  h * 0.5,
			-- bottom-right
			 w * 0.5,  h * 0.5,
			-- top-right
			 w * 0.5, -h * 0.5
		},
		friction = 1.5,
		-- isSensor = true
	})
end

	-- Haetaan kaikki viholliset kentästä.
	-- local enemies = map.getAllTiles( "isEnemy" )
	-- for i = 1, #enemies do
	-- 	local thisEnemy = enemies[i]
	-- 	if thisEnemy.id == "hat" then
	-- 		enemy[#enemy + 1] = hatModule.new( levelGroup, enemies[i] )
	-- 		enemy[#enemy]:startAI( player )
	-- 	end
	-- end


	-- local hearts = map.getAllTiles( "id", "heart" )
	-- for i = 1, #hearts do
	-- 	heartModule.new( levelGroup, hearts[i] )
	-- end


	-- local flag = map.getFirstTile( "id", "goal" )
	-- goalModule.new( levelGroup, flag )

	counterHP = ui.newCounterHP({
		parent = sceneGroup,
		x = screen.minX + 40,
		y = screen.minY + 24,
		fontSize = 24,
	} )

	levelBorder = display.newRect(
		map,
		screen.centerX - map.x,
		screen.centerY - map.y,
		map.designedWidth,
		map.designedHeight
	)

	levelBorder.fill = { 0, 0 }
	-- levelBorder.strokeWidth = 4
	-- levelBorder:setStrokeColor( 1, 0, 0 )
	levelBorder.id = "levelBorder"

	physics.addBody( levelBorder, "static", {
		isSensor = true,
		chain = {
			-map.designedWidth/2, -map.designedHeight/2,
			map.designedWidth/2, -map.designedHeight/2,
			map.designedWidth/2, map.designedHeight/2,
			-map.designedWidth/2, map.designedHeight/2
		},
		connectFirstAndLastChainVertex = true
	} )

	camera.start( player, {
		{ background, 1 },
		{ levelGroup, 1 },
		{ foreground, 1 },
	} )
end

-- show: kutsutaan kun scene on luotu mutta ei vielä näytetty.
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Ajetaan ennen kuin scene tulee näkyviin.


	elseif ( phase == "did" ) then
		-- Ajetaan heti kun scene näkyy pelaajalle.
		controls.start( movePlayer, keyPressed, player )
	end
end


-- hide: kutsutaan kun näkyvä scene halutaan piilottaa.
function scene:hide( event )
	sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Ajetaan ennen kuin scene katoaa näkyvistä.
		controls.stop()
		camera.stop()

	elseif ( phase == "did" ) then
		-- Ajetaan heti kun scene on piilotettu.


	end
end


-- destroy: kutsutaan kun scene halutaan poistaa kokonaan.
-- Täällä siivotaan kaikki objektit ja resurssit.
function scene:destroy( event )
	sceneGroup = self.view
	-- Ajetaan juuri ennen kuin scene tuhotaan.
	ui.menuGroup = nil
end


--------------------------------------------------------------------------------------
-- Scene event -kuuntelijat:
-- Voit valita mitä tapahtumia haluat kuunnella. Jos et esimerkiksi koskaan
-- poista sceneä, niin silloin "destroy" ei välttämättä ole tarpeellinen.
--------------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
--------------------------------------------------------------------------------------

-- Lopuksi palautetaan scene, jolloin tiedosto toimii Lua-moduulina.
return scene
