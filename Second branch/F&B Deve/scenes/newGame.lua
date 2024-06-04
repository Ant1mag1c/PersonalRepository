local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local characterData = require("data.characterData")
local widget = require( "widget" )
local screen = require( "scripts.screen" )
local loadsave = require( "scripts.loadsave" )

-- local button = {}

local charList = {}
for characterName, data in pairs( characterData ) do
    -- Haetaan pelaajahahmot dynaamisesti characterData tiedostosta.
    if data.info and data.info.isPlayer then
        charList[#charList+1] = characterName
    end
end

local selectedIndex = 1
local selectedChar

-- tekstipohjat
local imageLayer, infoLayer, statsLayer
-- Tekstit ja kuva
local description, stats, image, charName

local sceneGroup

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

--Tuodaan hahmon data näkyville ja tarvittaessa päivitetään sitä
local function updateImage(character)
    if description or stats then
        display.remove(charName)
        display.remove(description)
        display.remove(stats)
        display.remove(image)
    end

    table.print(character)

    local sheet = graphics.newImageSheet( character.sheet.image, character.sheet.sheetOptions )
    image = display.newSprite( sceneGroup, sheet, character.sheet.animSequences )
    image:play()
    image.x, image.y = imageLayer.x, imageLayer.y
    image.xScale, image.yScale = 3, 3

    charName = display.newText( sceneGroup, character.info.name, imageLayer.x, imageLayer.y - imageLayer.height*0.5 - 10, native.systemFont, 42 )
    charName.anchorY = 1

    description = display.newText( {
        parent = sceneGroup,
        text = character.info.description,
        x = infoLayer.x,
        y = infoLayer.y,
        width = infoLayer.width - 36,
        font = native.systemFont,
        fontSize = 26,
        align = "center"  -- Alignment parameter
    } )
    -- description:setFillColor( 1, 0, 0 )

    stats = display.newText( {
        parent = sceneGroup,
        text = "STARTING STATS\n\nSTR: " .. character.stats.strength .. " AGI: " .. character.stats.agility .. " INT: " .. character.stats.intellect,
        x = statsLayer.x,
        y = statsLayer.y,
        font = native.systemFont,
        fontSize = 20,
        align = "center"  -- Alignment parameter
    } )

end


-- Painettaessa Prev tai next otetaan hahmolistalta seuraava hahmo
local function changeChar(change)
    local nextIndex = selectedIndex + change
    selectedIndex = nextIndex

    if selectedIndex > #charList then
        selectedIndex = 1
    elseif selectedIndex < 1 then
        selectedIndex = #charList
    end

    selectedChar = characterData[charList[selectedIndex]]

    updateImage(selectedChar)
end


local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local id = event.target.id
        -- print( id )

        if id == "back" then
            composer.gotoScene( "scenes.mainMenu", { effect = "fade", time = 500 } )

        elseif id == "start" then
            -- Luodaan uusi gamedata ja vaihdetaan pelaajan hahmo valinnan mukaiseksi.
            loadsave.gamedata = table.copy( loadsave.userdata.newGame )
            loadsave.gamedata.character = table.copy( selectedChar.stats )
            -- Luodaan tyhjä "gear" taulukko, jossa on pelaajan varusteista saamat bonus/miinus statsit.
            loadsave.gamedata.character.gear = {}
            for k, _ in pairs( loadsave.gamedata.character ) do
                loadsave.gamedata.character.gear[k] = 0
            end
            loadsave.gamedata.character.name = charList[selectedIndex]

            composer.gotoScene( "scenes.game", {
                effect = "fade",
                time = 500,
            })

        elseif id == "next" then
            changeChar(1)

        elseif id == "previous" then
            changeChar(-1)

        end
    end
end


-- create()
function scene:create( event )
    sceneGroup = self.view

    local background = display.newImage( sceneGroup, "assets/images/uifolder/taustakuva.png", screen.centerX, screen.centerY )
    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end

    selectedChar = characterData[charList[1]]

    -- Luodaan pohjat scenen teksti objekteille
    imageLayer = display.newImage(sceneGroup, "assets/images/uifolder/hahmotausta.png", screen.centerX, screen.centerY*0.6 )
    infoLayer = display.newImage(sceneGroup, "assets/images/uifolder/kuvaustausta.png", screen.centerX, imageLayer.y + 180 )
    statsLayer = display.newImage(sceneGroup, "assets/images/uifolder/statsitausta.png", screen.centerX, infoLayer.y + 150 )

    updateImage( selectedChar )

    local buttonList = {
        button1 = {
            id = "back",
            label = "Back",
            x = screen.width*0.05,
            y = screen.height-20,
            fontSize = 32,
            onEvent = handleButtonEvent
        },

        button2 = {
            id = "start",
            label = "Start",
            x = screen.centerX*2,
            y = screen.height-20,
            fontSize = 32,
            onEvent = handleButtonEvent
        },

        button3 = {
            id = "next",
            label = "Next",
            x = imageLayer.x*1.3,
            y = imageLayer.y,
            fontSize = 32,
            onEvent = handleButtonEvent
        },

        button4 = {
            id = "previous",
            label = "prev",
            x = imageLayer.x*0.7,
            y = imageLayer.y,
            fontSize = 32,
            onEvent = handleButtonEvent
        },
    }

    -- Luodaan in pairs loopilla kaikille buttonList taulussa oleville painikkeille
    -- oma display objekti ja lisätään niille toiminnallisuus
    for key, value in pairs(buttonList) do
        local newButton = widget.newButton(
            {
                id = value.id,
                label = value.label,
                fontSize = value.fontSize,
                onEvent = value.onEvent
            }
        )
        newButton.y = value.y
        newButton.x = value.x

        sceneGroup:insert(newButton)
    end
end

-- show()
function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local phase = event.phase

    if ( phase == "will" ) then

        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )


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