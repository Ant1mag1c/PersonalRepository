-------------------------------------------------------------------------------------------------------

-- $$$$$$$\                                       $$$$$$\
-- $$  __$$\                                     $$  __$$\
-- $$ |  $$ | $$$$$$\   $$$$$$$\  $$$$$$\        $$ /  \__| $$$$$$\  $$$$$$\$$$$\   $$$$$$\   $$$$$$$\
-- $$$$$$$  |$$  __$$\ $$  _____|$$  __$$\       $$ |$$$$\  \____$$\ $$  _$$  _$$\ $$  __$$\ $$  _____|
-- $$  __$$< $$ /  $$ |\$$$$$$\  $$ /  $$ |      $$ |\_$$ | $$$$$$$ |$$ / $$ / $$ |$$$$$$$$ |\$$$$$$\
-- $$ |  $$ |$$ |  $$ | \____$$\ $$ |  $$ |      $$ |  $$ |$$  __$$ |$$ | $$ | $$ |$$   ____| \____$$\
-- $$ |  $$ |\$$$$$$  |$$$$$$$  |\$$$$$$  |      \$$$$$$  |\$$$$$$$ |$$ | $$ | $$ |\$$$$$$$\ $$$$$$$  |
-- \__|  \__| \______/ \_______/  \______/        \______/  \_______|\__| \__| \__| \_______|\_______/

-------------------------------------------------------------------------------------------------------
-- This template is proprietary and not licensed for public distribution.
-- Some third-party components included in this project are licensed under MIT.
-------------------------------------------------------------------------------------------------------

-- We're initialising the game's other core modules and settings inside a different
-- module in order to keep this main.lua file cleaner and easier to read.
local launchParams = require("data.launchParams")
require("libs.initGame").init( launchParams )

-------------------------------------------------------------------------

if launchParams.usesPixelArt then
	display.setDefault("magTextureFilter", "nearest")
	display.setDefault("minTextureFilter", "nearest")
end

-------------------------------------------------------------------------

-- Load composer and skip past launch screen in debug mode.
local composer = require("composer")

if launchParams.debugMode then
	composer.gotoScene( "scenes." .. (launchParams.gotoScene or "menu"), {params = launchParams.launchParams} )

else
	-- Always show error messages and stop the game's execution when running on the simulator.
	if system.getInfo( "environment" ) ~= "simulator" and launchParams.suppressErrors then
		-- Suppress error messages and try to ignore errors when not in debug mode.
		-- If you plan to include proper error reporting and analytics tools in your
		-- game, then feel free to replace the function below with your error handler.
		Runtime:addEventListener( "unhandledError", function()
			return true
		end )
	end

	composer.gotoScene( "scenes.launchScreen", {params = launchParams} )
end

---------------------------------------------------------------------------
