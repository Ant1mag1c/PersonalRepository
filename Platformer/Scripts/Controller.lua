local controller = {}

local controllerStarted = false
local pressedKey = {}
local target


-- Joka frame, katsotaan onko nämä liikkumisnapit painettuna alas.
local function monitorKeys()
	local vx, vy = 0, 0

	if pressedKey["a"] then
		vx = -1
	end
	if pressedKey["d"] then
		vx = vx + 1
	end
	if pressedKey["w"] then
		vy = -1
	end
	if pressedKey["s"] then
		vy = vy + 1
	end
	-- if target.move then
		target:move( vx, vy )

	end
-- end

-- Tarkkaillaan mitä nappeja pelaaja on painanut alas ja mitä hän ei enää paina.
local function onKeyEvent( event )
	-- print( event.phase, event.keyName )
	pressedKey[event.keyName] = event.phase == "down"

	if pressedKey["up"] then
		resistance = "fire"
		buttonUpdate()
	end
	if pressedKey["down"] then
		resistance = "water"
		buttonUpdate()
	end
	if pressedKey["left"] then
		resistance = "air"
		buttonUpdate()
	end
	if pressedKey["right"] then
		resistance = "earth"
		buttonUpdate()
	end

end



function controller.start( player )
	if controllerStarted then
		print( "Controller already started" )
	else
		controllerStarted = true
		target = player


		Runtime:addEventListener( "key", onKeyEvent )
		Runtime:addEventListener( "enterFrame", monitorKeys )
	end
end



function controller.stop()
	if not controllerStarted then
		print( "Controller needs to first be started." )
	else
		controllerStarted = false

		Runtime:removeEventListener( "key", onKeyEvent )
		Runtime:removeEventListener( "enterFrame", monitorKeys )


		for i, v in pairs( pressedKey ) do
			pressedKey[i] = false
		end
	end
end

return controller