-- PonyTiled extension for exit zone objects.
-- The exit object's "name" property in Tiled is the target map name (e.g. "outside").

local composer = require( "composer" )
local controls = require( "classes.controls" )

local M = {}

local transitioning = false

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	function instance:collision( event )
		if event.phase == "began" and event.other.name == "hero" then
			if transitioning then return end
			transitioning = true

			controls.stop()

			local targetMap = self.name
			composer.gotoScene( "scenes.refresh", {
				params = { mapName = targetMap }
			})
		end
	end

	function instance:finalize()
		transitioning = false
		instance:removeEventListener( "collision" )
	end
	instance:addEventListener( "finalize" )
	instance:addEventListener( "collision" )

	return instance
end

return M
