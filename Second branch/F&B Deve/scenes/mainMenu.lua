local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local menuButtons = {}
local widget = require( "widget" )
local screen = require( "scripts.screen" )
local saveExists

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local id = event.target.id

        -- Luodaan siirtymälle taulukko, ettei sen sisältöä tarvitse kirjoittaa useasti.
        local transitionOptions = {
            isModal = true,
            effect = "fade",
            time = 500,
            params = {
                action = "load",
            }
        }


        if id == "save" or id == "options" then
            -- Overlay on sen takia, että ei tarvitse siirtyä pelin aikana erillisen sceneen, vaan se tulee ns. pop uppina eteen.
            composer.showOverlay( "scenes." .. id, transitionOptions )

        elseif id == "exit" then
            native.requestExit()

        elseif id == "continue" then
            -- TODO:

        else
            composer.gotoScene( "scenes." ..id, transitionOptions)

        end
    end
end


function scene:create( event )

    local sceneGroup = self.view

    local background = display.newImage( sceneGroup, "assets/images/uifolder/taustakuva.png", screen.centerX, screen.centerY )
    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end

    local layer = display.newRect(sceneGroup, screen.centerX*0.35, screen.centerY, 300, screen.height-80)
    layer.alpha = 0.6
    layer:setFillColor(0.6)


    -- Alustetaan taulukko nimeltä idArray
    local bunttonData = {
        { "continue", "Continue" },
        { "newGame", "New Game" },
        { "save", "Load Game" },
        { "options", "Options" },
        { "credits", "Credits" },
        { "exit", "Exit" },
    }

    -- Tällä määritetään buttoneiden paikka ja nimi.
    local buttonSettings = {
        -- left = layer.x*1.2,
        -- top = 200,
        id = "newGame",
        label = "New Game",
        onEvent = handleButtonEvent
    }


    -- j kertoo kuinka monta kertaa looppi on juostu läpi.
    -- v = idArray[j] solu.
    -- ipairs juoksuttaa for loopin niinkauan, kuin soluja on.
    for i = 1, #bunttonData do
        -- * (i -1) avulla voi laittaa aloituspaikan juuri sille kohtaa, kun se on kirjoitettu.
        buttonSettings.top = 150 + 80 * (i-1)
        buttonSettings.id = bunttonData[i][1]
        buttonSettings.fontSize = 32

        -- buttonSettings.label kirjoitetaan painikkeen nimi.
        buttonSettings.label = bunttonData[i][2]
        -- Tämä luo buttoni muuttujat.
        menuButtons[i] = widget.newButton(buttonSettings)
        -- Annetaan buttonille layerin x-arvo
        menuButtons[i].x = layer.x
        -- Tämä lisää buttonit näkyväksi sceneen.
        sceneGroup:insert(menuButtons[i])
    end
end



function scene:show( event )
    local phase = event.phase

    if ( phase == "will" ) then

        -- Tämä looppi enabloi painikkeet näkyviksi.
        for i = 1, #menuButtons do
            menuButtons[i]:setEnabled( true )
        end
        -- Tarkistetaan onko jatkettavaa tallenustiedostoa ja jos sitä ei löydy niin
        -- asetetaan continue painike harmaaksi ja pois käytöstä
        saveExists = false

        if not saveExists then
            menuButtons[1].alpha = 0.3
            menuButtons[1]:setEnabled( false )
        end

    elseif ( phase == "did" ) then

    end
end

-- Piilottaa painikkeet
function scene:hide( event )
    local phase = event.phase

    if ( phase == "will" ) then
        for i = 1, #menuButtons do
            menuButtons[i]:setEnabled( false )
        end
        -- Code here runs when the scene is on screen (but is about to go off screen)
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