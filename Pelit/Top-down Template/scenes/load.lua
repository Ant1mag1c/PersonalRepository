local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require( "classes.screen" )
local saveManager = require( "classes.saveManager" )
local widget = require( "widget" )

---------------------------------------------------------------------------

-- Forward declarations & variables.
local currentMode
local currentGameState
local currentScreenshotFile
local currentFromGame
local currentIsOverlay
local currentOnClose
local buttonBack

local slotGroups = {}
local slotButtons = {}
local confirmGroup

local maxSlots = saveManager.getMaxSlots()

-- Layout constants.
local slotWidth = 136
local horizontalGap = 16
local verticalGap = 16

---------------------------------------------------------------------------

-- Functions.

-- Navigate back to game with the current game state.
local function returnToGame()
    if currentIsOverlay then
        composer.hideOverlay( "fade", 250 )
    elseif currentGameState then
        composer.gotoScene( "scenes.game", {
            effect = "fade",
            time = 500,
            params = {
                mapName = currentGameState.mapName,
                savedState = currentGameState,
            }
        })
    else
        composer.gotoScene( "scenes.menu", { effect = "fade", time = 500 } )
    end
end

---------------------------------------------------------------------------

-- Show a brief "Saved!" message and then return to game.
local function showSaveSuccess( sceneGroup )
    local savedText = display.newText({
        parent = sceneGroup,
        text = "Saved!",
        fontSize = 24,
        font = native.systemFontBold,
        x = screen.centerX,
        y = screen.centerY,
    })
    savedText:setFillColor( 0, 0.8, 0 )

    transition.to( savedText, {
        delay = 250,
        time = 250,
        alpha = 0,
        onComplete = function()
            display.remove( savedText )
            returnToGame()
        end
    })
end

---------------------------------------------------------------------------

-- Dismiss the confirmation dialog.
local function hideConfirmation()
    if confirmGroup then
        display.remove( confirmGroup )
        confirmGroup = nil
    end
    -- Re-enable slot buttons.
    for _, buttons in pairs( slotButtons ) do
        for _, btn in pairs( buttons ) do
            btn:setEnabled( true )
        end
    end
    if buttonBack then
        buttonBack:setEnabled( true )
    end
end

-- Show a confirmation dialog with a message and Yes/No buttons.
local function showConfirmation( sceneGroup, message, onConfirm )
    -- Disable slot buttons while confirmation is showing.
    for _, buttons in pairs( slotButtons ) do
        for _, btn in pairs( buttons ) do
            btn:setEnabled( false )
        end
    end
    if buttonBack then
        buttonBack:setEnabled( false )
    end

    confirmGroup = display.newGroup()
    sceneGroup:insert( confirmGroup )

    local dimmer = display.newRect( confirmGroup, screen.centerX, screen.centerY, screen.width, screen.height )
    dimmer:setFillColor( 0, 0.6 )

    local box = display.newRoundedRect( confirmGroup, screen.centerX, screen.centerY, 200, 90, 6 )
    box:setFillColor( 0.1, 0.95 )

    local text = display.newText({
        parent = confirmGroup,
        text = message,
        fontSize = 12,
        font = native.systemFont,
        width = 180,
        align = "center",
        x = screen.centerX,
        y = screen.centerY - 15,
    })

    local yesBtn = widget.newButton({
        x = screen.centerX - 40,
        y = screen.centerY + 25,
        id = "confirm_yes",
        label = "Yes",
        labelAlign = "center",
        labelColor = { default = { 0.9 }, over = { 1 } },
        width = 60,
        height = 22,
        fontSize = 12,
        font = native.systemFontBold,
        shape = "rect",
        fillColor = { default = { 0.5, 0, 0, 0.7 }, over = { 0.7, 0, 0, 0.9 } },
        onEvent = function( event )
            if event.phase == "ended" then
                hideConfirmation()
                if onConfirm then onConfirm() end
            end
            return true
        end,
    })
    confirmGroup:insert( yesBtn )

    local noBtn = widget.newButton({
        x = screen.centerX + 40,
        y = screen.centerY + 25,
        id = "confirm_no",
        label = "No",
        labelAlign = "center",
        labelColor = { default = { 0.9 }, over = { 1 } },
        width = 60,
        height = 22,
        fontSize = 12,
        font = native.systemFontBold,
        shape = "rect",
        fillColor = { default = { 0, 0.7 }, over = { 0, 0.9 } },
        onEvent = function( event )
            if event.phase == "ended" then
                hideConfirmation()
            end
            return true
        end,
    })
    confirmGroup:insert( noBtn )

    -- Block touches on the dimmer so they don't pass through.
    dimmer:addEventListener( "touch", function() return true end )
    dimmer:addEventListener( "tap", function() return true end )
end

---------------------------------------------------------------------------

-- Forward declare so the slot handler and createSlot can reference each other.
local createSlot

-- Handle save/load/remove button presses inside a slot.
local function handleSlotButton( event )
    if event.phase == "ended" then
        local id = event.target.id or ""
        local action, slotStr = id:match( "^(%a+)_(%d+)$" )
        local slotIndex = tonumber( slotStr )

        if not action or not slotIndex then return true end

        local sceneGroup = scene.view

        if action == "save" then
            local slotData = saveManager.loadFromSlot( slotIndex )
            if slotData then
                -- Slot has existing data, confirm overwrite.
                showConfirmation( sceneGroup, "Overwrite save in slot " .. slotIndex .. "?", function()
                    saveManager.saveToSlot( slotIndex, currentGameState, currentScreenshotFile )
                    showSaveSuccess( sceneGroup )
                end)
            else
                -- Empty slot, save immediately.
                saveManager.saveToSlot( slotIndex, currentGameState, currentScreenshotFile )
                showSaveSuccess( sceneGroup )
            end

        elseif action == "load" then
            local saveData = saveManager.loadFromSlot( slotIndex )
            if saveData and saveData.gameState then
                local loadParams = {
                    mapName = saveData.gameState.mapName,
                    savedState = saveData.gameState,
                }
                -- When the load scene is an overlay, the game scene is the
                -- active Composer scene.  gotoScene to the same scene is a
                -- no-op, so route through the refresh scene instead.
                local targetScene = currentIsOverlay and "scenes.refresh" or "scenes.game"
                composer.gotoScene( targetScene, {
                    effect = "fade",
                    time = 500,
                    params = loadParams,
                })
            end

        elseif action == "remove" then
            showConfirmation( sceneGroup, "Remove save in slot " .. slotIndex .. "?", function()
                saveManager.removeSlot( slotIndex )
                -- Refresh this slot's display.
                if slotGroups[slotIndex] then
                    local pos = slotGroups[slotIndex]._slotPos
                    local slotHeight = slotGroups[slotIndex]._slotHeight
                    display.remove( slotGroups[slotIndex] )
                    slotGroups[slotIndex] = nil
                    slotButtons[slotIndex] = nil
                    createSlot( sceneGroup, slotIndex, false, currentMode, pos.x, pos.y, slotWidth, slotHeight )
                    -- Enable the newly created buttons since we are in the "did" phase.
                    if slotButtons[slotIndex] then
                        for _, btn in pairs( slotButtons[slotIndex] ) do
                            btn:setEnabled( true )
                        end
                    end
                end
            end)

        end
    end
    return true
end

---------------------------------------------------------------------------

-- Create a single save slot's UI at the given position.
createSlot = function( sceneGroup, slotIndex, slotData, mode, posX, posY, slotWidth, slotHeight )
    local slotGroup = display.newGroup()
    sceneGroup:insert( slotGroup )

    -- Store position info for potential refresh.
    slotGroup._slotPos = { x = posX, y = posY }
    slotGroup._slotHeight = slotHeight

    slotGroups[slotIndex] = slotGroup
    slotButtons[slotIndex] = {}

    -- Slot background.
    local bg = display.newRoundedRect( slotGroup, posX, posY, slotWidth, slotHeight, 4 )
    bg:setFillColor( 0, 0.8 )

    local btnY = posY + slotHeight * 0.5 - 14
    local hasData = slotData and true or false

    if hasData then
        -- Timestamp at the top of the slot.
        local ts = display.newText({
            parent = slotGroup,
            text = saveManager.formatTimestamp( slotData.timestamp ),
            fontSize = 9,
            font = native.systemFont,
            x = posX,
            y = posY - slotHeight * 0.5 + 12,
        })
        ts:setFillColor( 0.7 )

        -- Attempt to load the screenshot.
        local screenshotLoaded = false
        if slotData.screenshotFile then
            local fullPath = system.pathForFile( slotData.screenshotFile, system.DocumentsDirectory )
            if fullPath then
                local file = io.open( fullPath, "r" )
                if file then
                    file:close()
                    local img = display.newImage( slotGroup, slotData.screenshotFile, system.DocumentsDirectory )
                    if img then
                        local maxW = slotWidth - 8
                        local maxH = slotHeight - 50
                        local scale = math.min( maxW / img.width, maxH / img.height )
                        img.xScale, img.yScale = scale, scale
                        img.x, img.y = posX, posY - 2
                        screenshotLoaded = true
                    end
                end
            end
        end

        if not screenshotLoaded then
            local placeholder = display.newText({
                parent = slotGroup,
                text = "Save #" .. slotIndex,
                fontSize = 14,
                font = native.systemFont,
                x = posX,
                y = posY - 2,
            })
            placeholder:setFillColor( 0.5 )
        end

        -- Remove button (slot has data).
        local removeBtn = widget.newButton({
            id = "remove_" .. slotIndex,
            label = "Remove",
            labelAlign = "center",
            labelColor = { default = { 0.9 }, over = { 1 } },
            onEvent = handleSlotButton,
            width = 46,
            height = 18,
            fontSize = 9,
            font = native.systemFont,
            shape = "rect",
            fillColor = { default = { 0.4, 0, 0, 0.8 }, over = { 0.6, 0, 0, 0.9 } },
            isEnabled = false,
        })
        removeBtn.x = posX + slotWidth * 0.5 - removeBtn.width - 50
        removeBtn.y = btnY
        slotGroup:insert( removeBtn )
        slotButtons[slotIndex].remove = removeBtn

        -- Action button (Save or Load).
        local actionLabel = mode == "save" and "Save" or "Load"
        local actionBtn = widget.newButton({
            id = (mode == "save" and "save_" or "load_") .. slotIndex,
            label = actionLabel,
            labelAlign = "center",
            labelColor = { default = { 0.9 }, over = { 1 } },
            onEvent = handleSlotButton,
            width = 42,
            height = 18,
            fontSize = 9,
            font = native.systemFont,
            shape = "rect",
            fillColor = { default = { 0, 0.7 }, over = { 0, 0.9 } },
            isEnabled = false,
        })
        actionBtn.x = posX + slotWidth * 0.5 - actionBtn.width * 0.5 - 4
        actionBtn.y = btnY
        slotGroup:insert( actionBtn )
        slotButtons[slotIndex].action = actionBtn

    else
        -- Empty slot.
        if mode == "save" then
            -- Show placeholder and Save button.
            local placeholder = display.newText({
                parent = slotGroup,
                text = "Save #" .. slotIndex,
                fontSize = 14,
                font = native.systemFont,
                x = posX,
                y = posY - 2,
            })
            placeholder:setFillColor( 0.5 )

            local actionBtn = widget.newButton({
                id = "save_" .. slotIndex,
                label = "Save",
                labelAlign = "center",
                labelColor = { default = { 0.9 }, over = { 1 } },
                onEvent = handleSlotButton,
                width = 42,
                height = 18,
                fontSize = 9,
                font = native.systemFont,
                shape = "rect",
                fillColor = { default = { 0, 0.7 }, over = { 0, 0.9 } },
                isEnabled = false,
            })
            actionBtn.x = posX + slotWidth * 0.5 - actionBtn.width * 0.5 - 4
            actionBtn.y = btnY
            slotGroup:insert( actionBtn )
            slotButtons[slotIndex].action = actionBtn

        else
            -- Load mode: empty slot, just show "Empty".
            local placeholder = display.newText({
                parent = slotGroup,
                text = "Empty",
                fontSize = 14,
                font = native.systemFont,
                x = posX,
                y = posY,
            })
            placeholder:setFillColor( 0.4 )
        end
    end

    -- Bring confirmation group to front if it exists.
    if confirmGroup then
        confirmGroup:toFront()
    end

    return slotGroup
end

---------------------------------------------------------------------------

-- Back button handler.
local function handleButtonEvent( event )
    if event.phase == "ended" then
        local id = event.target.id

        if id == "back" then
            if currentIsOverlay or currentFromGame then
                returnToGame()
            else
                composer.gotoScene( "scenes.menu", { effect = "fade", time = 500 } )
            end
        end
    end
    return true
end

---------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view

    -- Create local references to passed parameters.
    local sceneParams = event.params or {}
    currentMode = sceneParams.mode or "load"
    currentGameState = sceneParams.gameState
    currentScreenshotFile = sceneParams.screenshotFile
    currentFromGame = sceneParams.fromGame or false
    currentIsOverlay = sceneParams.isOverlay or false
    currentOnClose = sceneParams.onClose

    -- Reset slot tracking tables.
    slotGroups = {}
    slotButtons = {}
    confirmGroup = nil

    -----------------------------------------------------------------------
    -- Create background image to fill the screen.

    local background = display.newImage(
        sceneGroup, "assets/images/ui/menu.png",
        screen.centerX,
        screen.centerY
    )

    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end

    -----------------------------------------------------------------------
    -- Create title text.

    local titleText = currentMode == "save" and "Save" or "Load"
    local title = display.newText({
        parent = sceneGroup,
        text = titleText,
        fontSize = 20,
        font = native.systemFontBold,
        x = screen.centerX,
        y = screen.minY + 24,
    })
    title:setFillColor( 0 )

    -----------------------------------------------------------------------
    -- Calculate grid layout.

    local gridTop = screen.minY + 50
    local gridBottom = screen.maxY - 38
    local slotHeight = math.floor( (gridBottom - gridTop - verticalGap) / 2 )

    local col1X = screen.centerX - slotWidth * 0.5 - horizontalGap * 0.5
    local col2X = screen.centerX + slotWidth * 0.5 + horizontalGap * 0.5
    local row1Y = gridTop + slotHeight * 0.5
    local row2Y = gridTop + slotHeight + verticalGap + slotHeight * 0.5

    local positions = {
        { x = col1X, y = row1Y },
        { x = col2X, y = row1Y },
        { x = col1X, y = row2Y },
        { x = col2X, y = row2Y },
    }

    -----------------------------------------------------------------------
    -- Get save slot data and build the grid.

    local slotsInfo = saveManager.getAllSlotInfo()

    for i = 1, maxSlots do
        createSlot( sceneGroup, i, slotsInfo[i], currentMode, positions[i].x, positions[i].y, slotWidth, slotHeight )
    end

    -----------------------------------------------------------------------
    -- Create back button.

    buttonBack = widget.newButton({
        id = "back",
        label = "Back",
        labelAlign = "left",
        fontSize = 16,
        font = native.systemFont,
        labelColor = { default = { 0.9 }, over = { 1 } },
        fillColor = { default = { 0, 0.7 }, over = { 0, 0.9 } },
        width = 60,
        height = 26,
        onEvent = handleButtonEvent,
        shape = "rect",
        isEnabled = false,
    })
    buttonBack.x = screen.minX + 5
    buttonBack.y = screen.maxY - 5
    buttonBack.anchorX, buttonBack.anchorY = 0, 1
    sceneGroup:insert( buttonBack )
end

---------------------------------------------------------------------------

function scene:show( event )
    local sceneGroup = self.view

    if event.phase == "will" then


    elseif event.phase == "did" then
        -- Enable all buttons.
        buttonBack:setEnabled( true )
        for _, buttons in pairs( slotButtons ) do
            for _, btn in pairs( buttons ) do
                btn:setEnabled( true )
            end
        end

    end
end

---------------------------------------------------------------------------

function scene:hide( event )
    local sceneGroup = self.view

    if event.phase == "will" then
        -- Disable all buttons.
        buttonBack:setEnabled( false )
        for _, buttons in pairs( slotButtons ) do
            for _, btn in pairs( buttons ) do
                btn:setEnabled( false )
            end
        end

    elseif event.phase == "did" then
        if currentOnClose then
            currentOnClose()
            currentOnClose = nil
        end

    end
end

---------------------------------------------------------------------------

function scene:destroy( event )
    slotGroups = {}
    slotButtons = {}
    confirmGroup = nil
end

---------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------

return scene
