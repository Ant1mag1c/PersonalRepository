-- Ladataan Composer, jotta voimme käyttää sen funktioita.
local composer = require( "composer" )

-- Luodaan uusi scene-objekti.
local scene = composer.newScene()
local screen = require( "scripts.screen" )
local ui = require( "scripts.ui" )
local ponytiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )
local playerModule = require( "scripts.player" )
local heartModule = require( "scripts.heart" )
local wizardModule = require( "scripts.wizard" )
local projectileModule = require("scripts.projectileModule")
-- local goalModule = require( "scripts.goal" )
local controls = require( "scripts.controls" )
local loadsave = require( "scripts.loadsave" )
local camera = require( "scripts.camera" )
local effects = require("data.effects")
local debug = require("com.debug")

local background, levelGroup, foreground, objectGroup

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
	local _, currentVy = player:getLinearVelocity()

	player:move( vx, vy )
end

local function keyPressed( action, phase )
	-- print( "action", action, "phase", phase )

	if action == "menu" then
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

local function onEnterFrame()
end

local function onCollision( self, event )
	-- print( "collided with", event.other.id, "phase", event.phase )
	local phase = event.phase
	local other = event.other
	local id = event.other.id
	local myPart = event.selfElement == 1 and "body" or "leg" --1 = body, 2 = legs

	-- print(myPart)

	-- Jos pelaaja on kuollut, ei käsitellä muita törmäyksiä.
	if player.isDead then
		return
	end

	if phase == "began" then
		if myPart == "leg" and (id == "platform" or id == "obstacle" or id == "enemy")  then
			player:resetJumpCount()
			player.isClimbing = false
			player.onGround = true

		elseif id == "rope" then
			player:touchRope( true, other )
			player.touchedRope = other

			if id == "heart" then
				player:addHP( 1 )
				counterHP:update( player.currentHP )
			end

		elseif id == "goal" then
			event.other:complete()
			player.isDead = true
			controls.stop()
			menuOpen( "complete" )

		elseif not self.isImmortal and		( id == "projectile" or id == "spikes" ) then
			local damage = 1

			player:takeDamage( damage )
			counterHP:update( player.currentHP )

			display.remove(other)
			other = nil

			if player.isDead then
				controls.stop()
				menuOpen( "gameover" )
			end
		end


	elseif phase == "ended" then
		if id == "rope" then
			player:touchRope( false )

		elseif myPart == "leg" and (id == "platform" or id == "obstacle" or id == "enemy")  then
			player.onGround = false
		end

	end
end

local function onPreCollision(self, event)
	if not event and event.contact then return end
	-- print("preCollided with ", event.other.id)

	local other = event.other


	if player.isDead then
		return
	end



	if other.id == "rope" and other.isTopLayer then
		if self.onAir or self.isClimbing then
			event.contact.isEnabled = false
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

	background = map:findLayer( "foreground" )
	levelGroup = map:findLayer( "level" )
	objectGroup = map:findLayer( "objects" )
	foreground = map:findLayer( "background" )

	------------------------------------------------------------------------------
	-- Luodaan dynaamiset hahmot ja objektit:
	player = map:findObject( "player" )
	player = playerModule.new( levelGroup, player )

	player.collision = onCollision
	player:addEventListener( "collision" )
	player.preCollision = onPreCollision
	player:addEventListener("preCollision")

	-- Handle ropes/stairs
	local ropes = map.getAllTiles("name", "rope")

	for i = 1, #ropes do
		local ref = ropes[i]
		ropes[i].id = "rope"

		local isTop = ref.isTopLayer or false

		local hw = isTop and 8 or 2
		local y = isTop and 10 or 0

		local params = { halfWidth = hw, halfHeight = 8, y = y, x = 0 }
		local isSensor = not isTop and true or false

		physics.addBody( ref, "static", {
			box = params,
			isSensor = isSensor
		} )

	end

	-- Generate enemies
	local enemyRefs = map:findObjects("enemy")

	for i = 1, #enemyRefs do
		enemyRefs[i] = wizardModule.new(levelGroup, enemyRefs[i])
		enemy[i] = enemyRefs[i]
	end

	-- Generate phys bodies for objects
	local obstacles = map:findObjects("obstacle")

	for i = 1, #obstacles do
		local ref = obstacles[i]

		physics.addBody( ref, "static", { box = { halfWidth = 10, halfHeight = 8, y = 0, x = 0 } } )
	end

	-- Debug bullets
	local projectiles = map:findObjects("bullet")

	for i = 1, #projectiles do
		local ref = projectiles[i]
		local newProjectile = projectileModule:new( ref, player )

		display.remove(ref); projectiles[i] = nil
	end

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
	levelBorder.strokeWidth = 4
	levelBorder:setStrokeColor( 1, 0, 0 )
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
		{ objectGroup, 1 },
	}, levelBorder )
end

-- show: kutsutaan kun scene on luotu mutta ei vielä näytetty.
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

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


-- Run debugScene
timer.performWithDelay( 10, function ()
	debug.add( player, "onAir")
	debug.add( player, "onGround")
	debug.add( player, "isClimbing")
	debug.add( player, "ropeTouched")
end )


--------------------------------------------------------------------------------------
-- Scene event -kuuntelijat:
-- Voit valita mitä tapahtumia haluat kuunnella. Jos et esimerkiksi koskaan
-- poista sceneä, niin silloin "destroy" ei välttämättä ole tarpeellinen.
--------------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

Runtime:addEventListener("enterFrame", onEnterFrame)
--------------------------------------------------------------------------------------

-- Lopuksi palautetaan scene, jolloin tiedosto toimii Lua-moduulina.
return scene

