---------------------------------------------------------------------------
-- Save Manager
-- Handles save slot management and screenshot capture for the save/load system.
---------------------------------------------------------------------------

local saveManager = {}

local loadsave = require("classes.loadsave")

local MAX_SLOTS = 4
local SAVE_FOLDER = "saves"
local SAVE_VERSION = 1

---------------------------------------------------------------------------

-- Capture a screenshot of the entire screen and save to a temp file.
-- Must be called BEFORE showing any overlay or transitioning away.
-- Returns the temp file path (relative to system.DocumentsDirectory), or nil on failure.
function saveManager.captureScreenshot()
    local captured = display.captureScreen()
    if not captured then return nil end

    -- Position at content center so display.save captures the full screen.
    captured.x = display.contentCenterX
    captured.y = display.contentCenterY

    local tempFile = SAVE_FOLDER .. "/_temp_screenshot.png"

    display.save( captured, {
        filename = tempFile,
        baseDir = system.DocumentsDirectory,
        isFullResolution = false,
    })

    display.remove( captured )
    return tempFile
end

---------------------------------------------------------------------------

-- Copy a file from one path to another (binary safe).
local function copyFile( srcFilename, dstFilename, directory )
    local srcPath = system.pathForFile( srcFilename, directory )
    local dstPath = system.pathForFile( dstFilename, directory )

    if not srcPath or not dstPath then return false end

    local src = io.open( srcPath, "rb" )
    if not src then return false end

    local data = src:read( "*a" )
    src:close()

    local dst = io.open( dstPath, "wb" )
    if not dst then return false end

    dst:write( data )
    dst:close()
    return true
end

---------------------------------------------------------------------------

-- Save game state to a slot (1-4).
-- gameState: table of game data to persist.
-- tempScreenshotFile: path to temp screenshot (from captureScreenshot), or nil.
-- Returns true on success, false on failure.
function saveManager.saveToSlot( slotIndex, gameState, tempScreenshotFile )
    if slotIndex < 1 or slotIndex > MAX_SLOTS then
        print( "WARNING: saveManager.saveToSlot - invalid slot index: " .. tostring(slotIndex) )
        return false
    end

    local screenshotFile = SAVE_FOLDER .. "/screenshot_" .. slotIndex .. ".png"

    -- Copy temp screenshot to the slot-specific file.
    if tempScreenshotFile then
        copyFile( tempScreenshotFile, screenshotFile, system.DocumentsDirectory )
    end

    local saveData = {
        version = SAVE_VERSION,
        timestamp = os.time(),
        screenshotFile = screenshotFile,
        gameState = gameState or {},
    }

    return loadsave.save( saveData, SAVE_FOLDER .. "/save_" .. slotIndex )
end

---------------------------------------------------------------------------

-- Load game state from a slot.
-- Returns the full save data table, or false if slot is empty/invalid.
function saveManager.loadFromSlot( slotIndex )
    if slotIndex < 1 or slotIndex > MAX_SLOTS then
        return false
    end

    return loadsave.load( SAVE_FOLDER .. "/save_" .. slotIndex )
end

---------------------------------------------------------------------------

-- Remove a save slot and its screenshot.
function saveManager.removeSlot( slotIndex )
    if slotIndex < 1 or slotIndex > MAX_SLOTS then
        return false
    end

    -- Remove save data files (main + backup).
    loadsave.remove( SAVE_FOLDER .. "/save_" .. slotIndex )

    -- Remove the screenshot file.
    local screenshotPath = system.pathForFile(
        SAVE_FOLDER .. "/screenshot_" .. slotIndex .. ".png",
        system.DocumentsDirectory
    )
    if screenshotPath then
        os.remove( screenshotPath )
    end

    return true
end

---------------------------------------------------------------------------

-- Remove the temporary screenshot file.
function saveManager.removeTempScreenshot()
    local tempPath = system.pathForFile(
        SAVE_FOLDER .. "/_temp_screenshot.png",
        system.DocumentsDirectory
    )
    if tempPath then
        os.remove( tempPath )
    end
end

---------------------------------------------------------------------------

-- Get info for all save slots.
-- Returns a table indexed 1-4 where each entry is the save data table or false.
function saveManager.getAllSlotInfo()
    local info = {}
    for i = 1, MAX_SLOTS do
        info[i] = saveManager.loadFromSlot( i )
    end
    return info
end

---------------------------------------------------------------------------

-- Format a Unix timestamp into a human-readable string.
function saveManager.formatTimestamp( timestamp )
    if not timestamp then return "" end
    return os.date( "%Y-%m-%d %H:%M", timestamp )
end

---------------------------------------------------------------------------

-- Return the max number of slots.
function saveManager.getMaxSlots()
    return MAX_SLOTS
end

---------------------------------------------------------------------------

return saveManager
