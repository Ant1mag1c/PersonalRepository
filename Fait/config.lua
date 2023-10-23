--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--
local settings

-- Solar2D antaa varoituksia kun se ei pysty staattisesti analysoimaan tätä tiedostoa,
-- niin ohitetaan varoitus tarkistuksen aikana ja ladataan vasta oikealla käynnistyksellä
-- settings moduuli.
if _G.native then
	settings = require( "Scripts.settings" )
else
	settings = {
		userdata = {
			resolution = {
				width = 960,
				height = 640
			}
		}
	}
end

application =
{
	content =
	{
		width = settings.userdata.resolution.width,
		height = settings.userdata.resolution.height,
		scale = "letterbox",
		fps = 60,
	},
}
