--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--
local settings = require( "Scripts.settings" )

application =
{
	content =
	{
		width = settings.userdata.resolution.width,
		height = settings.userdata.resolution.height,
		scale = "letterbox",
		fps = 60,

		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}
