local composer = require( "composer" )

local scene = composer.newScene()
local settingsMenuContent = {}
local controlsMenuContent = {}
local settingsOn = false
local back
local sliders = {}
local sliderTexts = {}
local widget = require( "widget" )
local loadsave = require( "scripts.loadsave" )
local sfx = require( "scripts.updateAudio" )
local screen = require( "scripts.screen" )

local secondaryControlButtonToChange = nil
local keybindToChange = nil
local defaultFillColorButton = { default = { 0, 0, 0, 1 }, over={ 0.5, 0.5, 0.5, 1 } }

local removeListeners
local closeListener

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local id = event.target.id
        if id == "back" then
            -- composer.hideOverlay( "scenes.mainMenu", { effect = "fade", time = 500 } )
            composer.hideOverlay()

            if closeListener then
                closeListener()
                closeListener = nil
            end
        end
    end
end


-- Funktio, joka kutsutaan, kun slidereita liikutetaan.
local function sliderListener( event )
	-- Ajetaan alla oleva sisältö vain kun käyttäjä päästää sliderista irti.
	if event.phase == "ended" then
		-- print( "Slider \"" .. event.target.id .. "\" at " .. event.value .. "%" )

		-- Jokaisessa sliderissa on id, joka kertoo, mikä asetus on kyseessä. Tämä id on sama kuin
		-- userdata tiedoston avain, joten voimme tallentaa arvon userdataan.
		loadsave.userdata[event.target.id] = event.value
		-- loadsave.save( loadsave.userdata, "userdata.json" )

		-- Kutsutaan updateAudio moduulia, joka päivittää taustamusiikin ja äänien voimakkuudet.
		sfx.update()
	end
end

-- Funktio, joka kutsutaan, kun checkboxia painetaan.
local function onSwitchPress( event )
    local switch = event.target
    -- print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )

	-- Tallennetaan userdata tiedostoon, että fullscreen on päällä (tai ei ole, switch.isOn on true/false).
	loadsave.userdata["fullscreen"] = switch.isOn
	loadsave.save( loadsave.userdata, "userdata.json" )

	-- Muutetaan pelin ikkunan koko vastaamaan fullscreen tilaa.
	if switch.isOn then
		native.setProperty( "windowMode", "fullscreen" )
	else
		native.setProperty( "windowMode", "normal" )
	end
end


local function onMouseEvent( event )
	local isMouseButtonDown = event.isPrimaryButtonDown or event.isSecondaryButtonDown or event.isMiddleButtonDown
	local eventType = event.type
    if isMouseButtonDown then
        if eventType == "down" then
            local message = "Painikkeen vaihto peruttu."
            print( message )
            keybindToChange = nil
            removeListeners()
        end
    end
end

-- Palauttaa painikkeen värin default väriin.
local function restoreButtonColor(buttonObject, buttonColor)
    buttonObject:setFillColor(buttonColor[1], buttonColor[2], buttonColor[3], buttonColor[4])
end

local function onKeyEvent( event )

    if event.phase == "down" then
        local message

        local controlToChange

        -- TODO: Kirjoita käyttäjän valitsema painike defaultSettings.lua:n.

        -- Tarkastetaan, ettei valittu painike ole default-painikkeissa.
        for k,v in pairs(loadsave.userdata.controls) do
            -- Jos painettu painike löytyy defaulteista, niin estetään keybindin asettaminen.
            if v[1] == event.keyName then
                print("Yritettiin asettaa sama painike :(")
                for k,v in pairs(controlsMenuContent) do
                    -- Jos painike on sama, niin ilmoitetaan se punaisella värillä.
                    if v.id == event.keyName then
                        v:setFillColor( 1, 0, 0 )
                        local functionCall = function() return restoreButtonColor(v, defaultFillColorButton.default) end
                        timer.performWithDelay( 1000, functionCall )
                    end
                end
                keybindToChange:setFillColor( 1, 0, 0 )
                local secondaryKeyToRestore = keybindToChange
                local functionCall = function() return restoreButtonColor(secondaryKeyToRestore, defaultFillColorButton.default) end
                timer.performWithDelay( 1000, functionCall )
                keybindToChange = nil
                removeListeners()
                return
            end
        end

        -- Tarkastetaan, ettei valittu painike ole secondary-painike. Jos on, poistetaan vanha ja asetetaan uusi.
        for key,value in pairs(loadsave.userdata.controls) do
            if value[2] == event.keyName then
                print("Nollataan vanha painike :l", key)
                for k,v in pairs(controlsMenuContent) do
                    if v.id == key then
                        v:setLabel("")
                        -- TODO: Lisää tähän tallennus defaultSettings.luaan.
                    end
                end
            end
        end

        -- Tallennetaan käyttäjän valitsema painike (välimuistiin).
        loadsave.userdata.controls[keybindToChange.id][2] = event.keyName
        -- Luetaan tallennettu painike välimuistista painikkeen labeliin.
        keybindToChange:setLabel(loadsave.userdata.controls[keybindToChange.id][2])

        message = "Käyttäjä vaihtoi " .. keybindToChange.id .. " painikkeeksi " .. event.keyName
        print( message )

        keybindToChange = nil
        removeListeners()
    end

    return false
end

function removeListeners()
    Runtime:removeEventListener( "key", onKeyEvent)
    Runtime:removeEventListener( "mouse", onMouseEvent)
end

local function handleButtonPressEvent( event )

    if event.target.id == "settingsButtonid" then
        for k, v in pairs(settingsMenuContent) do
            v.isVisible = true
        end
        for k, v in pairs(controlsMenuContent) do
            v.isVisible = false
        end
    end

    if event.target.id == "controlsButtonid" then
        settingsOn = true
        print("Controls buttonia painettu")

        for k, v in pairs(settingsMenuContent) do
            v.isVisible = false
        end
        for k, v in pairs(controlsMenuContent) do
            v.isVisible = true
        end

    end

    -- for k,v in pairs(controlButtonidList) do
    --     if event.target.id == v[2] then
            if keybindToChange == nil then
                keybindToChange = event.target
                Runtime:addEventListener( "key", onKeyEvent )
                Runtime:addEventListener( "mouse", onMouseEvent)
                print("Halutaan vaihtaa painike  " .. keybindToChange.id)
            end
    --     end

    -- end
end


-- create()
function scene:create( event )
    local sceneGroup = self.view
    closeListener = event.params and event.params.closeListener

    local optionsGroupX = display.contentCenterX
    local optionsGroupY = 50

    local myText = display.newText( sceneGroup, "Options", optionsGroupX, optionsGroupY, native.systemFont, 16 )
    optionsGroupY = optionsGroupY + 50
    myText:setFillColor( 1, 0, 0 )

    local optionsBackground = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height  )
    optionsBackground:setFillColor( 0, 0.9 )

    local window = display.newImage( sceneGroup, "assets/images/uifolder/menutausta.png", screen.centerX, screen.centerY )

    local settingsButton = widget.newButton({
        x = optionsGroupX - 60,
        y = optionsGroupY,
        label = "Settings",
        id = "settingsButtonid",
        onPress = handleButtonPressEvent
    })

    local controlsButton = widget.newButton({
        x = optionsGroupX + 60,
        y = optionsGroupY,
        label = "Controls",
        id = "controlsButtonid",
        onPress = handleButtonPressEvent
    })

    sceneGroup:insert(settingsButton)
    sceneGroup:insert(controlsButton)

    -- Alustetaan taulukko nimeltä idArray
    local idArray = {}

    -- Annetaan arvot arrayn soluille 1-5
    idArray[1] = "masterVolume"
    idArray[2] = "musicVolume"
    idArray[3] = "sfxVolume"

    -- print(loadsave.userdata[idArray[1]])

    -- Alustetaan array nimeltä sliderTextList. Näitä käytetään slidereiden teksteinä.
    local sliderTextsList = {
        "Master volume",
        "Music volume",
        "SFX volume",
    }

    -- Tällä alustetaan sliderOptions.
    local sliderOptions = {
        x = optionsGroupX,
        y = optionsGroupY,
        id = "masterVolume",
        listener = sliderListener,
        value = 0
    }

    -- Tällä alustetaan sliderien tekstimuuttujat.
    local sliderTextOptions = {
		text = "",
		x = optionsGroupX,
		y = optionsGroupY - 20,
		font = native.systemFont,
		fontSize = 16
    }

    -- j kertoo kuinka monta kertaa looppi on juostu läpi.
    -- v = idArray[j] solu.
    -- pairs juoksuttaa for loopin niinkauan, kuin soluja on.
    for j, v in pairs(idArray) do

        -- Tällä haetaan defaultSettings.luasta arvot idArray taulukossa oleville teksteille.
        sliderOptions.value = loadsave.userdata[v]

        -- sliderOptions.y antaa ensimmäiselle slidereille paikan ja lisää joka kierroksella 100.
        -- * (j -1) avulla voi laittaa aloituspaikan juuri sille kohtaa, kun se on kirjoitettu.
        -- Luodaan sliderit.
        sliderOptions.y = optionsGroupY + 100 + 100 * (j -1)
        sliderOptions.id = v
        table.insert(settingsMenuContent, widget.newSlider(sliderOptions))

        -- Luodaan slidereiden tekstit.
        sliderTextOptions.text = sliderTextsList[j]
        sliderTextOptions.y = sliderOptions.y - 40
        table.insert(settingsMenuContent, display.newText(sliderTextOptions))

    end

    local fullscreenCheckbox = widget.newSwitch(
		{
			x = optionsGroupX,
			y = sliderOptions.y + 100,
			style = "checkbox",
			id = "Checkbox",
			onPress = onSwitchPress,
			initialSwitchState  = loadsave.userdata["fullscreen"],
		}
	)
    table.insert(settingsMenuContent, fullscreenCheckbox)

    table.insert(settingsMenuContent, display.newText("Fullscreen", optionsGroupX, fullscreenCheckbox.y - 40, native.systemFont, 16 ))

    for k, v in pairs(settingsMenuContent) do
        sceneGroup:insert(v)
    end

    back = widget.newButton(
        {
            left = 0,
            top = 10,
            id = "back",
            label = "Back",
            onEvent = handleButtonEvent
        }
    )
    sceneGroup:insert(back)

    -- Tähän alle tulee controls osio.----------------------------------------------------------------------

    local controlHeaders = {
        "action",
        "default",
        "secondary"
    }

    local controlHeaderAlignment = {
        "left",
        "center",
        "center"
    }

    local controlValues = {}

    local controlKeys = {
        "up",
		"down",
		"left",
		"right",
		"ability1",
		"ability2",
		"ability3",
		"ability4",
		"ability5",
		"ability6",
		"interact",
		"menu",
        "inventory"
    }

    for i = 1, #controlKeys do
        controlValues[controlKeys[i]] = loadsave.userdata.controls[controlKeys[i]]
    end

    local controlTexts = {}

    local controlKeyY = 150
    local controlKeyX = display.contentCenterX - 30
    local textRowSpacing = 35
    local textHorizontalSpacing = 100
    local controlButtons = {}
    local controlTextOptions
    local controlButtonOptions = {
        width = 80,
        height = textRowSpacing - 10,
        onPress = handleButtonPressEvent,
        emboss = false,
        shape = "roundedRect",
        cornerRadius = 2,
        fillColor = defaultFillColorButton,
        strokeColor = { default = { 0.5, 0.5, 0.5, 1 }, over={ 0, 0, 0, 1 } },
        strokeWidth = 3
    }

    -- Luodaan otsikot kontrolleille
    for i = 1, #controlHeaders do
        controlTextOptions = {
            parent = sceneGroup,
            text = controlHeaders[i],
            width = 100,
            x = controlKeyX + (i - 1) * textHorizontalSpacing,
            y = controlKeyY,
            font = native.systemFont,
            fontSize = 16,
            align = controlHeaderAlignment[i]
        }
        table.insert(controlsMenuContent, display.newText( controlTextOptions ))
    end

    -- Muutetaan elementtien Y-asemaa
    controlKeyY = controlKeyY + textRowSpacing

    -- Tehdään abilityjen tekstit
    for i = 1, #controlKeys do
        controlTextOptions = {
            parent = sceneGroup,
            text = controlKeys[i],
            width = 100,
            x = controlKeyX,
            y = controlKeyY + (i - 1) * textRowSpacing,
            font = native.systemFont,
            fontSize = 16,
            align = "left"
        }
        table.insert(controlsMenuContent, display.newText( controlTextOptions ))
    end

    -- Tehdään kontrollien painikkeet
    for i = 1, #controlKeys do

        -- Default painikkeet:
        controlButtonOptions.label = controlValues[controlKeys[i]][1]
        controlButtonOptions.x = controlKeyX + textHorizontalSpacing
        controlButtonOptions.y = controlKeyY + (i - 1) * textRowSpacing
        controlButtonOptions.id = controlValues[controlKeys[i]][1]
        print(controlButtonOptions.id)
        controlButtonOptions.isEnabled = false

        table.insert(controlsMenuContent, widget.newButton(controlButtonOptions))

        -- Secondary painikkeet:
        controlButtonOptions.label = controlValues[controlKeys[i]][2]
        controlButtonOptions.x = controlKeyX + (2 * textHorizontalSpacing)
        controlButtonOptions.y = controlKeyY + (i - 1) * textRowSpacing
        -- controlButtonOptions.id = controlButtonidList[controlKeys[i]][2]
        controlButtonOptions.id = controlKeys[i]
        controlButtonOptions.isEnabled = true

        table.insert(controlsMenuContent, widget.newButton(controlButtonOptions))
    end

    for k, v in pairs(controlsMenuContent) do
        sceneGroup:insert(v)
    end

    for k, v in pairs(controlsMenuContent) do
        v.isVisible = false
    end
end


-- show()
function scene:show( event )

    local phase = event.phase

end


-- hide()
function scene:hide( event )

    local phase = event.phase

end


-- destroy()
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