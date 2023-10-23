-- Piilotetaan statusbar (Androidissa, iOS:ssä, simulaattorilla, jne.)
display.setStatusBar( display.HiddenStatusBar )

require("Libs.utils")

local loadsave = require( "Libs.loadsave" )
loadsave.protectData( false )

------------------------------------------------------------

-- lataa asetukset kun peli käynnistyy
local settings = require("Scripts.settings")
audio.reserveChannels( 1 )
settings.setAudio()

-- resoluution tarkistus ja asetus
local platform = system.getInfo("platform")
if system.getInfo( "environment" ) ~= "simulator" then
    if platform == "android" then
        local androidVersion = string.sub( system.getInfo( "platformVersion" ), 1, 3 )
        if androidVersion and tonumber(androidVersion) >= 4.4 then
            native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
        elseif androidVersion then
            native.setProperty( "androidSystemUiVisibility", "lowProfile" )
        end
    elseif platform == "win32" or platform == "macos" then
        native.setProperty( "windowMode", settings.userdata.fullscreen and "fullscreen" or "normal" )
        native.setProperty( "windowSize", {
            width = settings.userdata.resolution.height,
            height = settings.userdata.resolution.width
        })
    end
end

------------------------------------------------------------

-- Ladataan ja prosessoidaan kaikki tsv-data tiedostot.
local dataHandler = require("Scripts.dataHandler")
dataHandler.getData( "cards.tsv" )
dataHandler.getData( "events.tsv" )
dataHandler.getData( "enemies.tsv" )
dataHandler.getData( "elites.tsv" )
dataHandler.getData( "bosses.tsv" )
dataHandler.getData( "playerCharacters.tsv" )

local composer = require("composer")
-- DEV: vaihda composer.gotoScene("scenes.mainMenu") -> composer.gotoScene("scenes.testattavanScenenNimi")
-- composer.gotoScene("scenes.mainMenu")
-- composer.gotoScene("scenes.battle")

-- composer.gotoScene("scenes.event", {
--     params = {
--         type = "luola",
--         terrain = "field",
--         level = 2,
--         row = 1
--             }
--     }
-- )


-- composer.gotoScene("scenes.deck", {
--     params = {
--         -- isStore = true,
--         isPharma = true,
--         eventCard = "viikate"
--         -- isTavern = true,
--     }
-- })

-- composer.gotoScene("scenes.map")

composer.showOverlay( "scenes.event", {
    params = {
        type = "apteekki",
    }
})
