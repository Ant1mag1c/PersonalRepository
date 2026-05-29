return {
	-------------------------------------

	-- When enabled, the game skips past the launch screen scene and goes
	-- directly to the "gotoScene" specified below. While in debugMode, the
	-- game also sends prints to the browser's console on HTML5 platform.
	debugMode = true,

	-------------------------------------

	-- When enabled, the game removes exisiting userdata.json and loads
	-- default settings on launch. Useful for testing default settings.
	cleanLaunch = false,

	-------------------------------------

	-- Whether or not to suppress runtime errors & messages when not in debug mode.
	-- This should always be set to false during a game's development.
	suppressErrors = false,

	-------------------------------------

	-- Sets master volume to zero at launch (may get overwritten later).
	muteGame = false,

	-------------------------------------

	-- Use the advanced audio library instead of Solar2D's default library.
	useAdvancedAudio = true,

	-- Game uses pixel art and should use nearest neighbour scaling instead of linear.
	usesPixelArt = true,

	-------------------------------------

	-- Set what scene the game starts in (after launch screen).
	gotoScene = "game",

	-------------------------------------
	-- launchScreen.lua contents and visual options:

	-- Logo image.
	logoFilename = "assets/images/launchScreen/RosoGamesWhiteWeb.png",
	logoWidth = 213,
	logoHeight = 269,
	logoOffsetX = 0,
	logoOffsetY = 0,
	logoAnchorX = 0.5,
	logoAnchorY = 0.5,

	-- Footer text.
	-- note: footer's text is updated automatically in main.lua to include the build year range.

	-- Footer properties:
	projectYear = 2026,
	font = native.systemFontBold,
	text = "nil",
	fontSize = 24,
	textAlign = "center",
	textWidth = 600,
	textOffsetX = 0,
	textOffsetY = -10,
	textAnchorX = 0.5,
	textAnchorY = 1,

	-- Logo & footer text transition options:
	showDelay = 250,
	showTime = 500,
	showEasing = easing.inOut,
	hideDelay = 1250,
	hideTime = 250,
	hideEasing = easing.inOut,

	-------------------------------------

	-- IMPORTANT:

	-- All properties inside the launchParams table below are sent to the scene the game launches in.
	-- This means you can add custom properties, like what level to start the game in, etc.

	-------------------------------------

	launchParams = {
		-- customProperty1 = "Hello World!",
		-- customProperty2 = 12345,
	},

	-------------------------------------
}