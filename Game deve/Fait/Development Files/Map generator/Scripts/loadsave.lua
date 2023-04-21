

local loadsave = {}

local json = require( "json" )

local defaultLocation = system.DocumentsDirectory

function mapLoadTable( filename, location)
    local loc = location
    if not location then
        loc = defaultLocation
    end
    -- Polku luettavalle tiedostolle
    local path = system.pathForFile( filename, loc )
    -- Käsiteltävä tiedosto
    local file, errorString = io.open( path, "r" )

    if not file then
        print( "File error: ", errorString )
        return false
    else
        -- Luetaan data tiedostosta
        local contents = file:read( "*a" )
        -- Decoodataan JSON data taulukkoon
        local t = json.decode( contents )
        io.close( file )
        return t
    end
end


function mapSaveTable(t, filename, location)
    local loc = location
    if not location then
        loc = defaultLocation
    end
    -- Tiedoston tallennuskansio
    local path = system.pathForFile( filename, loc )
    -- Polku käsiteltävälle tiedostolle
    local file, errorString = io.open( path, "w" )

    if not file then
        print( "File error: ", errorString )
        return false
    else
        -- Kirjoitetaan tallennettava tieto
        file:write( json.encode( t ) )
        io.close( file )
        print(t)
        return true
    end
end


return loadsave