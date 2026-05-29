local initGame = {}

function initGame.init( launchParams )

	---------------------------------------------------------------------------
	-- Step #1: Debug mode browser console prints.
	---------------------------------------------------------------------------

	-- If debug mode is active and the project is running on the
	-- HTML5 platform then send any prints to the browser console.

	if launchParams.debugMode and system.getInfo("platform") == "html5" then
		local _tostring = tostring
		local _concat = table.concat
		local _gsub = string.gsub

		-- Using lfs workaround to load JS modules outside of project root.
		local lfs = require("lfs")
		lfs.chdir( "widgets" )
		local printToBrowser = require("printToBrowser")
		local _print = printToBrowser.print

		-- Hijack the standard print function.
		local printList = {}
		function print( ... ) -- luacheck: ignore
			for i = 1, arg.n do
				printList[i] = _tostring( arg[i] )
			end
			_print( _gsub( _concat( printList, "    " ), "\t", "    " ) )
			-- Reduce, reuse and recycle.
			for i = 1, arg.n do
				printList[i] = nil
			end
		end

		-- Release widgets folder from LFS' control and clean up the library.
		lfs.chdir( system.pathForFile( "" ) )
		_G.package.loaded["lfs"] = nil
	end

	---------------------------------------------------------------------------
	-- Step #2: Initialize core modules and settings.
	---------------------------------------------------------------------------

	-- Initialize all core plugins, classes and libraries.
	require("widgets.eventListenerWrapper")
	require("classes.screen")
	require("libs.utils")

	if launchParams.useAdvancedAudio then
		-- NOTE: If you wish to use the standard audio API, then don't require this.
		-- The advanced audio library overwrites Solar2D's standard audio functions.
		require("libs.advancedAudio")
	end

	-- Set up useful properties that are likely needed later.
	local composer = require("composer")
	composer.recycleOnSceneChange = true
	transition.ignoreEmptyReference = true
	math.randomseed( math.generateSeed() )

	---------------------------------------------------------------------------
	-- Create a single global variable to track if the game is in debug mode.
	_G._debugMode = not not launchParams.debugMode
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- Step #3: Overwrite display.remove() and initialize core modules.
	---------------------------------------------------------------------------

	-- Overwriting Solar2D's original display.remove() convenience wrapper, which
	-- eliminates the need to check if a display object is nil before removing it.

	-- This version adds a property to the object upon removing it that explicitly states
	-- the object has been removed. There are some edge cases and race conditions where
	-- an object might have been removed, but doesn't yet appear so, and this property
	-- can be used to always verify if the object has been removed or not.

	display.remove = function( object )
		if type( object ) == "table" and not object._isRemoved then
			local method = object.removeSelf

			if type( method ) == "function" then
				object._isRemoved = true
				method( object ) -- same as object:removeSelf()
			end
		end
	end


	---------------------------------------------------------------------------
	-- Step #4: Set up the Loadsave module with extra checks and features.
	---------------------------------------------------------------------------
	-- The loadsave module (classes/loadsave.lua) is a general-purpose file I/O
	-- library. Here we wrap its save/load/remove functions with extra validation
	-- (filename checks, auto .json extension, folder creation, default value
	-- merging) and a consistent salt for data protection. These wrappers live
	-- here rather than in loadsave.lua itself so that the core module stays
	-- reusable and the beginner-friendly conveniences are applied in one place.
	---------------------------------------------------------------------------

	local loadsave = require("classes.loadsave")

	-- debugMode is set to false so that it doesn't raise warnings when using
	-- the hacked together version (in the way it's intended to be used).
	loadsave.debugMode( false )
	loadsave.protectData( false )

	---------------------------------------------------------------------------

	-- Adding extra checks to validating the savefile's name to help novice
	-- developers to understand what might be wrong, if something is wrong.
	local function validateFilename( filename, argumentIndex, source )
		if type( filename ) ~= "string" then
			print( "WARNING: bad argument #" .. argumentIndex .. " to '" .. source .. "' (string expected, got " .. type( filename ) .. ")." )
			return false

		else
			-- Replace any possible backward slashes in the filename with forward slashes.
			filename = string.gsub( filename, "%\\", "/" )

			-- If the filename does NOT include the .json filetype extension, then add it.
			if string.sub( filename, -5 ) ~= ".json" then
				filename = filename .. ".json"
			end

			-- Using gsub's substitution count to check if there are more periods in the filename
			-- string than the one in the expected/required file extension, .json.
			local _, substitutions = string.gsub( filename, "%.", "" )
			if substitutions > 1 then
				print( "WARNING: bad argument #" .. argumentIndex .. " to '" .. source .. "' (filename can only contain one period '.', got \"" .. filename .. "\")." )
				return false
			end
		end

		return filename
	end

	---------------------------------------------------------------------------

	-- Loop through tableFrom and copy any non-duplicate values to tableTo.
	local function copyNonDuplicates( tableTo, tableFrom )
		for key, value in pairs( tableFrom ) do
			if type( value ) == "table" then
				-- If the value is a table, create a new table if necessary and recursively copy.
				tableTo[key] = tableTo[key] or {}
				if type( tableTo[key] ) == "table" then
					copyNonDuplicates(tableTo[key], value)
				end
			else
				-- Only copy the value if it doesn't already exist in tableTo.
				if tableTo[key] == nil then
					tableTo[key] = value
				end
			end
		end
	end

	---------------------------------------------------------------------------
	-- Overwrite the module's original save function to validate the filename,
	-- provide more in-depth error messages, as well as include a single salt.

	local _save = loadsave.save

	function loadsave.save( data, filename )
		local validFilename = validateFilename( filename, 2, "save" )
		if not validFilename then
			return false
		end

		-- If the filename contains any forward slashes, then it'll be saved to some folder
		-- inside the documents directory. Create the required folders if they don't exist.
		local folderPathEnd = string.findLast( validFilename, "/" )
		if folderPathEnd then
			system.createFolder( string.sub( filename, 1, folderPathEnd-1 ), system.DocumentsDirectory )
		end

		return _save( data, validFilename, "RosoGames" )
	end

	---------------------------------------------------------------------------
	-- Overwrite the module's original load function to validate the filename,
	-- provide more in-depth error messages, as well as include a single salt.
	-- Also adds optional loading of default contents for savefiles. Adding new
	-- properties to the default contents will get added to the existing savefile
	-- on subsequent loads of the file.

	local _load = loadsave.load

	function loadsave.load( filename, defaultContents )
		local validFilename = validateFilename( filename, 1, "load" )
		if not validFilename then
			return false
		end

		-----------------------------------------------------------------------

		local savedata = _load( validFilename, "RosoGames" )
		local defaultContentType = type( defaultContents )

		-- Process the savefile's possible defaultContents.
		if defaultContentType == "string" or defaultContentType == "table" then
			local defaultData

			-- If defaultContents are a string, then try loading the .lua file the string points to.
			if defaultContentType == "string" then
				-- Ensure there are no forward or backward slashes, or the filetype extension in the string.
				defaultContents = string.gsub( string.gsub( defaultContents, "%\\", "/" ), "/", "%." )
				if string.sub( defaultContents, -4 ) == ".lua" then
					defaultContents = string.sub( defaultContents, 1, -5 )
				end

				-----------------------------------------------------------------------

				-- Attempt to load the defaultContents file.
				local success, errorMessage = pcall( function()
					defaultData = require( defaultContents )
				end )

				-----------------------------------------------------------------------

				if not success then
					if string.find( errorMessage, "not found" ) then
						print( "ERROR: bad argument #2 to 'get'. Unable to find \"" .. defaultContents .. "\"." )
					else
						print( "ERROR: bad argument #2 to 'get'. Unable to load \"" .. defaultContents .. "\" due to error:\n" .. errorMessage .. "\n" )
					end
					return false
				end

			else
				-- If defaultContents are a table, then just copy it.
				defaultData = table.copy( defaultContents )

			end

			if not defaultData then
				print( "WARNING: failed to load defaultContents." )
			else
				savedata = savedata or {}
				copyNonDuplicates( savedata, defaultData )
			end
		end

		return savedata
	end

	---------------------------------------------------------------------------
	-- Removes a savefile and its backup from disk.

	function loadsave.remove( filename )
		local validFilename = validateFilename( filename, 1, "remove" )
		if not validFilename then
			return false
		end

		os.remove( system.pathForFile( "backup_" .. validFilename, system.DocumentsDirectory ) )
		os.remove( system.pathForFile( validFilename, system.DocumentsDirectory ) )
	end

	---------------------------------------------------------------------------
	-- Step #4b: Create the saves folder for save game files.
	---------------------------------------------------------------------------
	system.createFolder( "saves", system.DocumentsDirectory )

	---------------------------------------------------------------------------
	-- Step #5: Load user settings from disk and apply them.
	---------------------------------------------------------------------------

	-- Clean up possible old userdata if requested.
	if launchParams.cleanLaunch then
		loadsave.remove( "userdata.json" )
	end

	-- Load user settings or create them from default settings if not found.
	local userdata = loadsave.load( "userdata.json" )
	if not userdata then
		userdata = require( "data.defaultSettings" )
		loadsave.save( userdata, "userdata.json" )
	end

	if userdata.fullscreen then
		native.setProperty( "windowMode", "fullscreen" )
	else
		native.setProperty( "windowMode", "normal" )
	end

	-- Apply audio settings if using the advanced audio library.
	if launchParams.useAdvancedAudio then

		local channels = userdata.audio.channels
		if channels then
			for channelType, channelInfo in pairs( channels ) do
				if type( channelInfo ) == "table" and type( channelInfo.from ) == "number" and type( channelInfo.to ) == "number" then
					audio.assignChannelTypes( channelInfo.from, channelInfo.to, channelType )
				end
			end
		end

		local volumes = userdata.audio.volume
		if volumes then
			for volumeType, volumeLevel in pairs( volumes ) do
				if volumeType ~= "master" and type( volumeLevel ) == "number" then
					audio.setVolume( volumeLevel / 100, volumeType )
				end
			end
			audio.setVolume( volumes.master / 100 )
		end
	end

	-- Silence the game by setting the master volume to zero.
	if launchParams.muteGame then
		audio.setVolume( 0 )
	end

	---------------------------------------------------------------------------
	-- Step #6: Store userdata in Loadsave module for easy access.
	---------------------------------------------------------------------------

	loadsave.userdata = table.copy( userdata )

end

return initGame
