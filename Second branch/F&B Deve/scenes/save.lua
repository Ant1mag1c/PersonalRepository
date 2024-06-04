-- Lataa Composer-kirjasto
local composer = require("composer")

-- Luo uusi scene-olio
local scene = composer.newScene()

-- Alusta tallennustiedot
local saveFile = {}
local save = {}
local saveCount = 3

-- Lataa widget-kirjasto
local widget = require( "widget" )
local screen = require( "scripts.screen" )

-- Funktio, joka tuodaan game scenestä ja joka kutsutaan kun tämä overlay scene suljetaan.
local closeListener

-- Funktio painikkeiden käsittelyä varten
local function handleButtonEvent(event)
    if ("ended" == event.phase) then
        local id = event.target.id
        if id == "back" then
            -- composer.gotoScene("scenes.mainMenu", { effect = "fade", time = 500 })
            composer.hideOverlay()
            if closeListener then
                closeListener()
                closeListener = nil
            end

        else
            print("Load save")
        end
    end
end


-- Luo scene: create -toiminto
function scene:create(event)
    local sceneGroup = self.view
    local params = event.params or {}
    closeListener = params.closeListener

    -- "save" scene toimii "Load Game" ja "Save Game" scenenä, niin tarkistetaan kumpaa pelaaja haluaa käyttää.
    -- Tämän jälkeen luodaan halutusta toiminnosta isolla alkukirjaimella alkava nimi, "Save" tai "Load". Tätä
    -- voidaan käyttää myöhemmin UI:n luonnissa.
    local sceneType = params.action:sub(1,1):upper() .. params.action:sub(2)

    local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
    background:setFillColor( 0, 0.9 )


    local title = display.newText(sceneGroup, sceneType .. " Game", display.contentCenterX, display.screenOriginY + 20, native.systemFont, 32)
    title:setFillColor(1, 0, 0)

    -- Luo "Back" -painike
    local back = widget.newButton(
        {
            left = display.screenOriginX,
            top = display.actualContentHeight - 50,
            id = "back",
            label = "Back",
            fontSize = 32,
            onEvent = handleButtonEvent
        }
    )
    sceneGroup:insert(back)

    -- Luo "Load Save" -painike
    local load = widget.newButton(
        {
            left = display.actualContentWidth - 200,
            top = display.actualContentHeight - 50,
            id = params.action,
            label = sceneType,
            fontSize = 32,
            onEvent = handleButtonEvent
        }
    )
    sceneGroup:insert(load)

    local window = display.newImage( sceneGroup, "assets/images/uifolder/menutausta.png", screen.centerX, screen.centerY )

    -- Luo tallennustiedostoille napit.
    local frameY = window.y * 0.5

    for i = 1, saveCount do
        save[i] = {}
        save[i].frame = display.newRect(sceneGroup, display.contentCenterX, frameY, 320, 80)
        save[i].frame:setFillColor( 0.2 )

        save[i].loadImage = display.newRect(sceneGroup, save[i].frame.x * 0.8, frameY, 70, 70)
        save[i].loadText = display.newText(sceneGroup, "Player lvl:", save[i].frame.x, save[i].frame.y - 20, native.systemFont, 20)
        save[i].loadDate = display.newText(sceneGroup, "xx-xx-xxxx, xx:xx", save[i].frame.x + 25, save[i].frame.y + 20, native.systemFont, 20)

        frameY = frameY + 100
    end
    -- print("Load Game")
end

-- Luo scene: show -toiminto
function scene:show(event)
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen

    end
end

-- Luo scene: hide -toiminto
function scene:hide(event)
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end

-- Luo scene: destroy -toiminto
function scene:destroy(event)
end

-- Kuuntele tapahtumia
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-- Palauta scene
return scene
