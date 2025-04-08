local loadsave = {}

local json = require( "json" )

-- Tallennetaan data tiedostoon JSON muodossa.
function loadsave.save( data, filename )
	-- Path for the file to write
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	-- Open the file handle
	local file, errorString = io.open( path, "w" )

    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Write encoded JSON data to file
        file:write( json.prettify( json.encode( data ) ) )
        -- Close the file handle
        io.close( file )
        return true
    end
end

-- Luetaaan JSON tiedosto ja palautetaan se Lua taulukkona.
function loadsave.load( filename )
	-- Path for the file to read
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	-- Open the file handle
	local file, errorString = io.open( path, "r" )

	if not file then
		-- Error occurred; output the cause
		print( "File error: " .. errorString )
	else
		-- Read data from file
		local contents = file:read( "*a" )
		-- Decode JSON data into Lua table
		local data = json.decode( contents )
		-- Close the file handle
		io.close( file )
		-- Return table
		return data
	end
end

return loadsave