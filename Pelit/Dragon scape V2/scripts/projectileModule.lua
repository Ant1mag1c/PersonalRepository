local emitterModule = require("scripts.emitter")
local effects = require("data.effects")
local callback
local startX, startY
local body
local speed, maxTravel, direction = 50, 120, nil

local t = {}



function t:new( from, to )
	local offset = from.id == "enemy" and 10 or 0
	local fromX, fromY = from.x, from.y - offset
	local speed = 30

    body = emitterModule.new( from.parent, fromX, fromY, "fireball" )
	body.id = "projectile"
	body.rotation = math.deg(math.atan2( to.y - from.y, to.x - from.x ))

	physics.addBody(body, "dynamic", { radius = 4, isSensor = true, filter = {
        categoryBits = 4,
        maskBits = 0xFFFF
    } } )

	body.gravityScale = 0

	-- Send bullet toward target
	local rad = math.rad(body.rotation)
	local vx = math.cos(rad) * speed
	local vy = math.sin(rad) * speed

	body:setLinearVelocity(vx, vy)



	local function onCollision( event )
		if event.phase == "began" then
			-- print( "collided with", event.other.id, "phase", event.phase )
			local other = event.other.id

			if other == "player" or other == "platform" or other == "obstacle" then
				display.remove(body)
				-- print( "Projectile killed" )
			end
		end
	end


	self.collision = onCollision
	body:addEventListener( "collision", onCollision )

	return body
end


return t