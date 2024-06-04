local composer = require( "composer" )

local scene = composer.newScene()
local physics = require("physics")
-- physics.setDrawMode( "hybrid" )

physics.start()
physics.setGravity( 0, 0 )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local loadsave = require( "scripts.loadsave" )
local screen = require( "scripts.screen" )
local character = require( "scripts.character" )
local controls = require( "scripts.controls" )
local shadowText = require( "scripts.shadowText" )
local collisionData = require( "data.collisionData" )
local inventory = require( "scripts.inventory" )
local toolbar = require( "scripts.toolbar" )
local ponyfont = require( "com.ponywolf.ponytiled" )
local camera = require( "scripts.camera" )
local json = require( "json" )

-- Funktioita
local onKeyEvent, updateEnemy, onGlobalCollision

-- Display objektit ja ryhmät
local player
local sceneGroup, menuGroup

local groupLevel = display.newGroup()
local groupUI = display.newGroup()

-- Muut ennakkoon esitellyt muuttujat
local map, menuKey, enemyList
local enemyCount = 0
local overlayOpen = false

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------


local function pauseGame( pause )
    if pause then
        physics.pause()
		controls.stop()
    else
        physics.start()
        controls.start( player )
    end
end


local function onCloseOverlay()
    overlayOpen = false
end


local function showCutscene( id )
    print( id )
end


-- Menun tapahtumat
local function menuButton(event)
    if event.phase == "ended" then
        local id = event.target.id

        if id == "options" then
            overlayOpen = true
            composer.showOverlay("scenes." .. id, { effect = "fade", time = 0, params = { closeListener = onCloseOverlay } })

        elseif id == "load" or id == "save" then
            overlayOpen = true
            composer.showOverlay("scenes.save", { effect = "fade", time = 0, params = { action = id, closeListener = onCloseOverlay } })

        elseif id == "continue" then
            -- Päivitetään menu näppäimet jos pelaaja on käynyt menussa vaihtamassa niitä.
            menuKey = controls.updateKeys()

            display.remove( menuGroup )
            menuGroup = nil

            -- Älä palauta kontrolleja, jos inventory on vielä auki.
            if not inventory.isOpen then
                pauseGame( false )
            end
        else
            composer.gotoScene("scenes." .. id, { effect = "fade", time = 500 })

        end
    end

    return true
end


-- Näytetään "menu/pause" ikkuna.
local function toggleMenu()
    pauseGame( true )

    -- Luodaan menu omaan menuGroup ryhmäänsä, mutta lisätään se ryhmä sceneGrouppiin,
    -- jotta peli pystyy hallitsemaan sitä mahdollisten scene vaihdosten aikana.
    menuGroup = display.newGroup()
    groupUI:insert( menuGroup )

    -- Luo tausta, joka täyttää koko näytön
    local bg = display.newRect(menuGroup, display.contentCenterX, display.contentCenterY, screen.width, screen.height )
    bg:setFillColor(0, 0.5)

    local window = display.newImage( menuGroup, "assets/images/uifolder/menutausta.png", screen.centerX, screen.centerY )

    local buttonSpacing = 20
    local buttonY = bg.y - bg.height * 0.5 + 50

    shadowText.new({
        parent = menuGroup,
        text = "Paused",
        x = bg.x,
        y = buttonY+100,
        fontSize = 72,
    })

    buttonY = buttonY + 100

    local buttonData = {
        { text = "Load Game", id = "load" },
        { text = "Save Game", id = "save" },
        { text = "Options", id = "options" },
        { text = "Continue", id = "continue" },
        { text = "Quit", id = "mainMenu" }
    }

    for i = 1, #buttonData do
        local button = shadowText.new({
            parent = menuGroup,
            text = buttonData[i].text,
            x = bg.x,
            y = buttonY + 100,
            fontSize = 40,
        })
        button.id = buttonData[i].id
        button:addEventListener("touch", menuButton)

        buttonY = buttonY + button.height + buttonSpacing
    end
end


local function addListeners()
    menuKey = controls.updateKeys()
    Runtime:addEventListener( "key", onKeyEvent )
    Runtime:addEventListener( "collision", onGlobalCollision )
    Runtime:addEventListener( "enterFrame", updateEnemy )
end


local function removeListeners()
    Runtime:removeEventListener( "key", onKeyEvent )
    Runtime:removeEventListener( "collision", onGlobalCollision )
    Runtime:removeEventListener( "enterFrame", updateEnemy )
end


-- Kontrolloi mitä tapahtuu, kun pelaaja painaa mitä tahansa näppäintä.
function onKeyEvent( event )
	local keyName = menuKey[event.keyName]
    -- print( "onKeyEvent - game:", keyName, event.phase )

	-- Jos näppäintä ei ole määritetty pelin asetuksissa, niin älä tee mitään.
	if keyName then
        if event.phase == "down" then

            if keyName == "menu" then
                if overlayOpen then
                    composer.hideOverlay()
                    overlayOpen = false
                end

                -- Jos menua ei ole, niin luodaan se. Muussa tapauksessa lähetetään "fake" touch event
                -- menuButton funktioon ja käytetään kyseisen menun "continue" eventtiä sulkemaan menu.
                if not menuGroup then
                    toggleMenu()
                else
                    menuButton({ target={ id="continue" }, phase="ended" })
                end

            elseif keyName == "inventory" then
                -- Estä inventoryn kontrollointi, jos menu on auki.
                if menuGroup then
                    return
                end


                if inventory.isOpen then
                    inventory.remove()
                    player.updateToolbar()
                    pauseGame( false )

                else
                    inventory.create()
                    pauseGame( true )

                end
            end
        end
    end
end



function onGlobalCollision( event )
    local phase = event.phase
    local obj1, obj2 = event.object1, event.object2

    -- luacheck: ignore character
    local character, vimpain

    -- Vain pelaajaan tai viholliseen voi osua jokin asia. Tarkastetaan kummam id on törmäyksessä kyseessä ja tehdään siitä character viittaus
    if obj1.isPlayer or obj1.isEnemy then
        character = obj1
        vimpain = obj2
    else
        character = obj2
        vimpain = obj1
    end

    -- Tarkista jos pelaaja osuu transition tai cutscene elementteihin.
    if character.isPlayer and not vimpain.onEffect then
        -- print( "onGlobalCollision", phase, vimpain.type, vimpain.name, vimpain.level )

        if vimpain.type == "transition" then
            loadsave.gamedata.map = vimpain.level
            composer.gotoScene( "scenes.reloadScene" )

        elseif vimpain.type == "cutscene" then
            showCutscene( vimpain.name )

        end
    end

    -- Vain vimpaimilla on onEffect, eli jos pelaaja ja vihollinen tai kaksi vihollista törmäävät keskenään, niin mitään ei tapahdu.
    if vimpain.onEffect then
        vimpain:onEffect( character, phase )
    end
end


function updateEnemy()
    for i = 1, #enemyList do
        local thisEnemy = enemyList[i]

        if thisEnemy.isDead then
            return
        end

        thisEnemy.track( player )
    end
end


-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create( event )
    local sceneParams = event.params or {}
    sceneGroup = self.view

    -- Laitetaan debug fysiikat piirtoon, jos devaaja haluaa.
    if sceneParams.physicsDrawMode == "hybrid" then
        physics.setDrawMode( "hybrid" )
    end

    -- Mennään joko annettuun kenttään, tai siirretään pelaaja vain johonkin kenttään, ettei peli kaadu.
    local mapName = sceneParams.map or loadsave.gamedata.map
    -- Lisätään kenttä tiedostoon sen polku ja tiedostotyyppi.
    mapName = "assets/" .. mapName .. ".json"

    -- Luodaan debug areena, jossa pelinkehittäjä voi nopeasti testata uusia vimpaimia, tekoälyä, jne.
    if sceneParams.debugArena then
        local fence = display.newRect( groupLevel, screen.centerX + 220, screen.centerY + 120, 100, 100 )
        physics.addBody( fence, "static", { filter = collisionData.terrainFilter } )

        -- Luodaan debug vihollisia.
        enemyList =
        {
            ["enemy1"] =
            {
                ["x"] = display.contentCenterX,
                ["y"] = display.contentCenterY+50,
            },

            ["enemy2"] =
            {
                ["x"] = display.contentCenterX-100,
                ["y"] = display.contentCenterY+50,
            },
        }

        enemyCount = table.count( enemyList )

        for i = 1, enemyCount  do
            local enemyData = enemyList["enemy" .. i]
            local newEnemy = character.new( groupLevel, enemyData.x, enemyData.y, "shroomWhite" )
            enemyList[i] = newEnemy
        end

        player = character.new( groupLevel, screen.centerX, screen.centerY-200, "player", sceneParams.invulnerability )

    -- Ladataan oikea, ei-debug kenttä.
    else
        -- Ladataan ja luodaan pelikartta.
        local mapData = json.decodeFile( system.pathForFile( mapName, system.ResourceDirectory ) )
        map = ponyfont.new( mapData, "assets" )
        groupLevel:insert( map )

        -- Haetaan spawn lokaatiot kartasta ja asetetaan pelaaja oikeaan.
        local spawnLocation = map:_getAllObjects( "spawn" )

        local spawn
        for i = 1, #spawnLocation do
            spawn = spawnLocation[i]
            if spawn.spawn == sceneParams.spawn then
                break
            end
        end

        local layerCharacter = map:findLayer( "charactersAndObjects" )
        player = character.new( layerCharacter, spawn.x, spawn.y, "player", sceneParams.invulnerability )

        local enemyLocation = map.getAllTiles( "isEnemy", true )
        enemyList = {}

        for i = 1, #enemyLocation do
            display.remove( enemyLocation[i] )

            enemyList[i] = character.new( layerCharacter, enemyLocation[i].x, enemyLocation[i].y, enemyLocation[i].name )
        end

        player:toFront()
    end

    -- Järjestetään display groupit haluttuun z-järjestykseen, esim. kentän pitää olla hahmojen takana
    -- ja hahmojen tulee olla pelin UI:n takana, jne.
    sceneGroup:insert( groupLevel )
    sceneGroup:insert( groupUI )
end



function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
        toolbar.create( groupUI )
        if not event.params or not event.params.debugArena then
            camera.start( player, {
                { groupLevel, 1 }
            } )
        end

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
        pauseGame( false )



        if loadsave.gamedata.map then
            addListeners()

        else
            addListeners()
        end
	end
end



function scene:hide( event )
	sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
        pauseGame( true )
        inventory.remove()
        camera.stop()

        removeListeners()

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
        toolbar.remove()
        map = nil

	end
end



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