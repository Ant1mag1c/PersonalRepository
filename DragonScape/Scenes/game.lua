
--[[
 - Luo lohikäärmeen logiikka. Miten ampuu / käyttäytyy
 - Viimeistele ensimmäinen taso
 - Luo toinen taso

	--ADVANCED--

 - Luo pelaaja moduuliin funktio hallinnoimaan animaatioita
 - Korjaa kontrollit. Nyt pelaaja ei liiku jos ylöspäin painetaan
]]

local dragon

local composer = require( "composer" )

local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Ladataan erilaisia ulkoisia moduuleita joita hyödynnetään myöhemmin.
local loadsave = require( "Scripts.loadsave" )
local tiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )

-- Ladataan fysiikka kirjasto ja käynnistetään fysiikka simulaatio.
local physics = require( "physics" )
physics.start()
physics.setDrawMode( "hybrid" )

-- Ladataan lisää game.lua kohtaisia moduuleita.
local shadowText = require( "Scripts.shadowText" )
local controls = require( "Scripts.controls" )
local camera = require( "Scripts.camera" )
local playerScript = require( "Scripts.player" )
local enemyScript = require( "Scripts.enemy" )
local finishScript = require( "Scripts.finish" )
local dragon = require( "Scripts.dragon" )
local gamedata = require( "Scripts.gamedata" )
local projectile = require( "Scripts.projectile" )
local calc = require( "Scripts.calc" )


local player, hpCounter
local level, map, gameOver
local movePlayer, onKeyEvent
local menuGroup, sceneGroup, levelGroup

local orb = {}
local projectileList = {}


-- Julistetaan scenen funktiot
-- removeObjects poistaa kaikki listenerit sekä objectit. setDefault antaa gamedata.lualle oletus arvot
local newScene, removeData, setDefault, update, shootProjectile, createProjectile


-- Ladataan ääniefektit muistiin. Huom! Nämä pitää poistaa muistista erikseen. Solar2D ei tee sitä automaattisesti.
local sfxHurt = audio.loadSound( "Audio/hurt.mp3" )
local sfxJump = audio.loadSound( "Audio/jump.mp3" )
local sfxWin = audio.loadSound( "Audio/complete.mp3" )
local sfxLose = audio.loadSound( "Audio/gameover.mp3" )
local sfxFire = audio.loadSound( "Audio/shootfire.mp3" )

local musicOptions =

		{
			channel = 1,
			loops = -1,
		}

local backgroundMusic = audio.loadStream( "Audio/ost.mp3" )
audio.play( backgroundMusic, musicOptions )

audio.setVolume( 0.2, { channel=1 } )

-- Koska haluamme näyttää peliruudussa pelaajan elämät, niin luodaan imageSheet, jossa nämä grafiikat ovat.
local options =
{
	-- The params below are required
	width = 18,
	height = 18,
	numFrames = 64,
}
local imageSheet = graphics.newImageSheet( "Maps/Tiles/tilemap.png", options )

-- Mitä tehdään jos ja kun pelaaja painaa menu-nappeja.
local function menuButton( event )
	if event.phase == "ended" then
		if event.target.id == "restart" then
			loadsave.save( loadsave.userdata, "userdata.json" )

			composer.gotoScene( "Scenes.reloadScene", { effect = "fade", time = 200, params={
				level = level
			} } )


		elseif event.target.id == "back" then
			loadsave.save( loadsave.userdata, "userdata.json" )

			composer.gotoScene( "Scenes.menu", { effect = "fade", time = 500 } )

		elseif event.target.id == "continue" then
			local backgroundGroup = map:findLayer( "background" )
			local levelGroup = map:findLayer( "level" )
			local foregroundGroup = map:findLayer( "foreground" )

			-- Käynnistetään kamera, kontrollit ja fysiikka simulaatio uudelleen.
			camera.start( player, {
				{ backgroundGroup, 1 },
				{ levelGroup, 1 },
				{ foregroundGroup, 1 },
			} )

			controls.start( movePlayer, onKeyEvent )

			physics.start()

		end

		-- Poistetaan menu-valikko. Koska menuGroup ei ole liitetty composerin sceneGroupiin, niin se ei poistu automaattisesti.
		display.remove( menuGroup )
		menuGroup = nil

	end
	return true
end

-- Näytetään "menu/pause" ikkuna.
local function showWindow( windowType )
	-- Pysäytetään kamera, kontrollit ja fysiikka simulaatio. Tämä tehdään, jotta pelaaja ei voi liikkua tai
	-- tehdä mitään, kun menu/pause ikkuna on näkyvissä.
	physics.pause()
	camera.stop()
	controls.stop()

	-- Luodaan menu omaan menuGroup ryhmäänsä. Koska ryhmää ei aseteta composerin sceneGroupiin, niin se ei poistu
	-- automaattisesti ja se menee kaikkien muiden elementtien päälle.

	menuGroup = display.newGroup()

	local bg = display.newRect( menuGroup, display.contentCenterX, display.contentCenterY, 600, 400 )
	bg:setFillColor( 0, 0.85 )

	shadowText.new({
		parent = menuGroup,
		text = windowType:upper() .. "!",
		x = bg.x,
		y = bg.y - bg.height * 0.5 + 50,
		font = "Fonts/munro.ttf",
		fontSize = 72,
	})

	local restart = shadowText.new({
		parent = menuGroup,
		text = "Restart Level",
		x = bg.x,
		y = bg.y + 30,
		font = "Fonts/munro.ttf",
		fontSize = 40,
	})
	restart.id = "restart"
	restart:addEventListener( "touch", menuButton )

	local back = shadowText.new({
		parent = menuGroup,
		text = "Back to main menu",
		x = restart.x,
		y = restart.y + restart.height + 10,
		font = "Fonts/munro.ttf",
		fontSize = 40,
	})
	back.id = "back"
	back:addEventListener( "touch", menuButton )

	-- Lisätään "Continue"-nappi vain jos kyseessä on "pause" ikkuna. "victory" ja "defeat" ikkunoissa ei ole "Continue"-nappia.
	if windowType == "pause" then
		local continue = shadowText.new({
			parent = menuGroup,
			text = "Continue",
			x = back.x,
			y = back.y + back.height + 10,
			font = "Fonts/munro.ttf",
			fontSize = 40,
		})
		continue.id = "continue"
		continue:addEventListener( "touch", menuButton )
	end

end

-- #Collision
-- Aina kun pelaaja törmää jonkin asian kanssa, niin tämä funktio kutsutaan.
local function onLocalCollision( self, event )
	local other = event.other
	local otherType = other.tileType
	-- print( self.tileType, event.other.tileType )

	-- Törmäys alkoi, niin katsotaan minkä tyyppisen asian kanssa pelaaja törmäsi.
    if ( event.phase == "began" ) then
		if otherType == "finish" and gamedata.winCondition then
			audio.play( sfxWin )
			removeData()
			gameOver = true
			showWindow( "victory" )


		elseif otherType == "sphere" then
			-- print(other, otherType)
			gamedata.obeliskCount = gamedata.obeliskCount - 1

			display.remove(other)

		elseif otherType == "ground" then
			if player.jumpCount == 1 then
				local nextSequence = player.xDir ~= 0 and "move" or "idle"

				player:setSequence(nextSequence)
				player:play()
			end

			player.jumpCount = 0

		elseif otherType == "rope" then
			player.jumpCount = 0

			player.ropesTouched = player.ropesTouched + 1
			if player.ropesTouched ==  1 then
				player.gravityScale = 0
			end

		elseif otherType == "enemy" or otherType == "spike" then
			local _vx, _vy = player:getLinearVelocity()

			player:setLinearVelocity( -_vx, -_vy )

			controls.stop()

			player.hp = player.hp - 1

			if player.hp > 0 then
				audio.play( sfxHurt )
			end

			display.remove( hpCounter )

			local counterIndex = 23 - player.hp
			hpCounter = display.newImageRect( sceneGroup, imageSheet, counterIndex, 18, 18 )
			hpCounter.x, hpCounter.y = display.contentCenterX, display.screenOriginY + 20
			hpCounter.xScale, hpCounter.yScale = 2, 2

			if player.hp == 0 then
				player.alpha = 0

				if dragon.fireTimer then
					player:setLinearVelocity(0)
					timer.pause(dragon.fireTimer)

					for i = 1, #projectileList do
						print( projectileList[i].stop )
						timer.performWithDelay(1, function() display.remove(projectileList[i] ) end )
					end

				end
			else
				timer.performWithDelay( 300, function()
					controls.start( movePlayer, onKeyEvent )
				end )

			end

		elseif otherType == "trampoline" then
			player.touchingTrampoline = true

		elseif otherType == "coin" then
			if not other.collected then
				audio.play( sfxCoin )
				other.collected = true
				other.isVisible = false
				loadsave.userdata.coinsCollected = loadsave.userdata.coinsCollected + 1

				timer.performWithDelay( 1, function()
					display.remove( other )
				end )

			end
		end

	-- Törmäys loppui, niin katsotaan minkä tyyppisen asian kanssa pelaaja oli törmännyt.
    elseif ( event.phase == "ended" ) then
		if otherType == "rope" then
			player.ropesTouched = player.ropesTouched - 1

			if player.ropesTouched <= 0 then
				player.gravityScale = 1
			end

		elseif otherType == "trampoline" then
			player.touchingTrampoline = false

		end

    end
end


local prevDirectionX = 0
-- #Move
function movePlayer( xDir, yDir )
	local moveSpeed = player.moveSpeed

	if player.jumpCount == 0 then
		if prevDirectionX == 0 and xDir ~= 0 then
			player:setSequence("move")
		elseif prevDirectionX ~= 0 and xDir == 0 then
			player:setSequence("idle")
		end

		player:play()
	end


	if xDir ~= 0 and xDir ~= prevDirectionX then
		player.xScale = xDir
	end

	local _vx, _vy = player:getLinearVelocity()

	-- Jos pelaaja koskee köyteen, eikä tämä erikseen liiku y-akselilla, niin pysäytetään pelaajan y-akselin nopeus.
	local touchingRope = player.ropesTouched > 0
	if yDir == 0 and touchingRope and not player.isJumping then
		_vy = 0
	end

	-- Jos pelaaja ei liiku y-akselilla, niin käytetään pelaajan nykyistä y-akselin nopeutta.
	-- Tämän myötä pelaajan y-akselin nopeus ei muutu, kun pelaaja hyppää tai putoaa.
	if yDir == 0 then
		player:setLinearVelocity( xDir * moveSpeed, _vy )
	else
		if touchingRope then
			player:setLinearVelocity( _vx*0.9, yDir * moveSpeed )
		else
			player:setLinearVelocity( _vx, _vy )
		end
	end

	prevDirectionX = xDir
	player.xDir = xDir

	-- Päivitetään pelaajan sijainti helpommin seurattavaan muotoon
	gamedata.playerRef.x, gamedata.playerRef.y = player.x, player.y

	if gamedata.printPlayer then
		print("Player X  " .. player.x .. " Y " ..  player.y)
	end
end

-- Pelaaja painoi jotain asetuksissa määritettyä näppäintä, niin tämä funktio kutsutaan.
function onKeyEvent( key, phase )
	-- print( key, phase )
	if phase == "down" then
		if key == "jump" then
			if player.jumpCount >= player.maxJumpCount then
				return
			end
			player.jumpCount = player.jumpCount + 1

			audio.play( sfxJump )
			player:setSequence("jump")
			player:play()

			local _vx, _vy = player:getLinearVelocity()

			player:setLinearVelocity( _vx, 0 )

			local jumpForce = -0.02
			local jumpModifier = 1
			if player.touchingTrampoline then
				jumpModifier = 1.5
			end

			player:applyLinearImpulse( 0, jumpForce*jumpModifier, player.x, player.y )
			player.isJumping = true

		elseif key == "menu" then
			showWindow( "pause" )

		end

	elseif phase == "up" then
		if key == "jump" then
			player.isJumping = false
		end

	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	function newScene()
	    sceneGroup = self.view
	    -- Code here runs when the scene is first created but has not yet appeared on screen

		level = event.params and event.params.level or nil
		-- print( "level = ", level )

		if not level then
			print( "ERROR: No level specified!" )
		end

		-- Ladataan haluttu kenttä Maps kansiosta. Tiedoston on oltava json muodossa.
		local mapData = json.decodeFile(system.pathForFile("Maps/" .. level .. ".json", system.ResourceDirectory))
		-- Lisätään ladatun kentän tiedot ulkoiseen ponytiled moduuliin, jotta se osaa luoda kentän.
		map = tiled.new(mapData, "Maps")
		sceneGroup:insert( map ) -- Lisätään kenttä sceneGroupiin, jotta se poistuu automaattisesti, kun scene poistuu.

		-- Haetaan kartasta "level" niminen layer, johon kaikki kentän elementit on lisätty. Tätä voidaan käyttää
		-- kun seuraavaksi haemme kartasta pelaajan ja vihollisten, yms. sijainnit ja luomme niiden tilalle erilliset objektit.
		levelGroup = map:findLayer( "level" )

		local playerRef = map.getFirstTile( "isPlayer" )
		player = playerScript.new( levelGroup, playerRef )
		player.collision = onLocalCollision
		player:addEventListener( "collision" )
		gamedata.playerRef = player

		local enemyRef = map.getAllTiles( "isEnemy" )
		if enemyRef and #enemyRef > 0 then
			for i = 1, #enemyRef do
				enemy[i] = enemyScript.new( levelGroup, enemyRef[i] )
				enemy[i].enemyType = enemyRef[i].enemyType
			end
		end

		local boundData = map.getAllTiles( "tileType", "border" )

		if #boundData == 4 then
			local _b1 = boundData[1]
			local _b2 = boundData[2]
			local _b3 = boundData[3]
			local _b4 = boundData[4]

			local mapBounds =
			{
				right = math.max( _b1.x,  _b2.x,  _b3.x,  _b4.x ),
				left = math.min( _b1.x,  _b2.x,  _b3.x,  _b4.x ),
				top = math.min( _b1.y,  _b2.y,  _b3.y,  _b4.y ),
				bottom = math.max( _b1.y,  _b2.y,  _b3.y,  _b4.y )
			}

			gamedata.mapBounds = mapBounds
		else
			print("ERROR! invalid ammount of borders")

		end


		local spikeRef = map.getAllTiles( "tileType", "spike" )
		if spikeRef and #spikeRef > 0 then
			for i = 1, #spikeRef do
				physics.removeBody( spikeRef[i] )

				local offsetRectParams = { halfWidth=9, halfHeight=5, x=0, y=5 }

				physics.addBody( spikeRef[i], "static", { bounce = 1, box=offsetRectParams })
			end
		end


		local finishRef = map.getFirstTile( "tileType", "finish" )
		local finish = finishScript.new( levelGroup, finishRef )
		-- print( finishRef )

		-- Lisätään vielä perään "hpCounter", joka näyttää pelaajan jäljellä olevan HP:n.
		hpCounter = display.newImageRect( sceneGroup, imageSheet, 21, 18, 18 )
		hpCounter.x, hpCounter.y = display.contentCenterX, display.screenOriginY + 20
		hpCounter.xScale, hpCounter.yScale = 2, 2

		-- #Book: Ladataan kirjojan image ja tuodaan kirjat kenttään
		local book = {}
		local bookSheet = graphics.newImageSheet( "Images/books.png", { width=32, height=32, numFrames=2 } )

		for i = 1, 1 do
			-- book[i] = display.newImageRect( levelGroup, bookSheet, i, 32, 32 )
			-- book[i].x, book[i].y = player.x, player.y
		end

		-- TODO:
		-- #Barrier

		-- #Dragon
		dragon = dragon.new( levelGroup, player.x+100, player.y-400 )

		-- dragon.fireTimer = timer.performWithDelay(200, function()
		-- 	local newProjectile = dragon.shoot( dragon.xScale )
		-- 	table.insert(projectileList, newProjectile)
		-- end, 1 )


		local mapBounds = gamedata.mapBounds
		-- #Update
		local function update(event)
			dragon.scan(player)

			if projectileList and projectileList[1] then
				for i = #projectileList, 1, -1 do
					local _projectile = projectileList[i]

					-- Dynamically check out-of-bounds condition
					local offMap = _projectile.x > mapBounds.right or
						_projectile.x < mapBounds.left or
						_projectile.y > mapBounds.bottom

					if offMap then
						print( "Removed:", _projectile )
						display.remove( _projectile )
						table.remove( projectileList, i )
					end
				end
			end


			-- -- TODO:
			-- if dragon.x > mapBounds.right or dragon.x < mapBounds.left then
			-- 	dragon.start( -dragon.xScale )
			-- end

			if gamedata.printDragon then
				print("Dragon x:", dragon.x)
			end
		end

		Runtime:addEventListener("enterFrame", update)
	end

	newScene()
end


-- show()
function scene:show( event )
    sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

		-- Haetaan kartasta erikseen kaikki layerit, jotta ne voidaan antaa kameran käyttöön.
		local backgroundGroup = map:findLayer( "background" )
		local levelGroup = map:findLayer( "level" )
		local foregroundGroup = map:findLayer( "foreground" )

		-- Halutessamme voisimme laittaa jotkut layerit liikkumaan kamerassa hitaammin tai nopeammin,
		-- mutta tässä esimerkki projektissa kaikki liikkuvat täyttä 100% (1.0) nopeutta.
		camera.start( player, {
			{ backgroundGroup, 1 },
			{ levelGroup, 1 },
			{ foregroundGroup, 1 },
		} )

		-- Muutetaan taustan väriä, jotta kentät näyttävät paremmilta jos niissä on tyhjiä kohtia.
		display.setDefault( "background", 148/255, 176/255, 255/255 )

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

		-- Kun koko kenttä on näkyvissä, niin käynnistetään kontrollit.
		controls.start( movePlayer, onKeyEvent )

    end
end



-- hide()
function scene:hide( event )
    sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

		-- Peli alkaa siirtymään pois game scenestä, niin estetään kontrollit.
		controls.stop()

		-- Pysäytetään kaikki äänikanavat.
		for i = 2, 32 do
			audio.stop( i )
		end

		-- Vapautetaan kaikki ääniefektit muistista.
		audio.dispose( sfxJump )
		audio.dispose( sfxCoin )
		audio.dispose( sfxWin )
		audio.dispose( sfxLose )

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

		-- Peli on siirtynyt pois game scenestä, niin pysäytetään kamera.
		camera.stop()
		dragon.stop()
		gameOver = true
		audio.stop( 1 )

		display.setDefault( "background", 0 )
    end
end


-- destroy()
function scene:destroy( event )
    sceneGroup = self.view
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