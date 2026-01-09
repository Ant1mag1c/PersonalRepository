local emitterModule = require("scripts.emitter")
local effects = require("data.effects")
local callback
local startX, startY
local body
local speed, maxTravel, direction = 50, 120, nil

local t = {}

local function update()
	if math.abs(body.x - startX) > maxTravel then
		body.remove()
	end
end


function t.new( enemyRef, x, y, func )
    direction = enemyRef.lookDir
	callback = func
    startX, startY = x, y

    body = emitterModule.new( enemyRef._parent, x, y, "fireball" )
	body.id = "projectile"
	physics.addBody(body, "dynamic", {
		radius = 12,
		isSensor = true,
	} )

	body.gravityScale = 0
	body:setLinearVelocity(direction*speed, 0)

    Runtime:addEventListener( "enterFrame", update )

	function body.remove( playerHit )
		if not playerHit then
			transition.to(body, {
				time = 100,
			    startColorAlpha = 0,
			    finishColorAlpha = 0,
				onComplete = callback(body)
			})
		else
			callback(body)
		end

		Runtime:removeEventListener( "enterFrame", update )
	end

	return body
end


return t