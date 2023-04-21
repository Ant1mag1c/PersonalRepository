-- -----------------------------------------------------------------------------------
local settings = {}
local json = require( "json" )  -- Include the Corona JSON library

-- !!! debuggaus hardkoodattu clean startti joka peli avaukseen !!!
-- TODO: poista tämä kun debuggaus on valmis
local cleanStart = true

settings.userdata = {
	masterVolume = 50,
	musicVolume = 50,
	fxVolume = 50,
	language = "english",
	fullscreen = false,
	resolution = { width = 640, height = 960}
}
 
local path = system.pathForFile( "settings.json", system.DocumentsDirectory )

-- Open the file handle
local file, errorString = io.open( path, "r" )

-- tallennusfunktio
function settings.save()
    -- Path for the file to write
    local path = system.pathForFile( "settings.json", system.DocumentsDirectory )
    
    -- Open the file handle
    local file, errorString = io.open( path, "w" )
    
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
    else
        -- Write data to file
        file:write( json.prettify( json.encode( settings.userdata ) ))
        -- Close the file handle
        io.close( file )
    end
    
    file = nil
end

-- peli käynnistyy ensimmäistä kertaa tai asetustiedostoa ei löydy
if not file or cleanStart then
    settings.save()
else
    -- Read data from file
    local contents = file:read( "*a" )
    -- Decode JSON data into Lua table
    settings.userdata = json.decode( contents )
    -- Close the file handle
    io.close( file )
end

-- audiotasojen asetukset
function settings.setAudio()
    audio.setVolume( settings.userdata.masterVolume / 100 )
    audio.setVolume( settings.userdata.musicVolume / 100, { channel = 1 } )
    for i = 2, 32 do
        audio.setVolume( settings.userdata.fxVolume / 100, { channel = i } )
    end
end



return settings
-- -------------------------------------------------------------------------