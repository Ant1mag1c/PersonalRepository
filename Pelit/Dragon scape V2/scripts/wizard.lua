local effects = require("data.effects")
local emitterModule = require("scripts.emitter")
local projectileModule = require("scripts.projectileModule")
local raycast = require("scripts.raycast")
local animation = require("data.animation")
local player


local enemy = {}


local sequence = animation.sequences["enemy"]
local sheet = graphics.newImageSheet(
	animation.sheets["enemy"],
	animation.data["enemy"]
)



function enemy.new( parent, reference )
	local x, y = reference.x, reference.y

	if reference then
		display.remove(reference)
	else
        return false
	end

    local newEnemy = display.newSprite(sheet, sequence)
	parent:insert( newEnemy )

	newEnemy.x, newEnemy.y = x, y
	newEnemy.xScale, newEnemy.yScale = 0.5, 0.5
	newEnemy.anchorY = 0.8
	newEnemy.id = "enemy"
	newEnemy.lookDir = 1

	local bodies = {
		{
	        box = { halfWidth = 6, halfHeight = 8, y = -10, x = 0 },
			userData = "body",
			density = 10
	    },

		{
			radius = 2,
			userData = "foot"
	    }
	}

	physics.addBody( newEnemy, "dynamic", bodies[1], bodies[2])
	newEnemy.isFixedRotation = true

	local state = "idle"
	local lookDir = 1
	local speed = 20
	local health = 1

	local playerSeen = false
	local floorAhead = false



	local function setState(newState)
		if state == newState then return end

		-- Check that newState exists in data
		for i = 1, #animation.sequences do
			local name = animation.sequences[i].name

			if not newState == name then print("WARNING Invalide sequence") return false end
		end
		state = newState

		newEnemy:setSequence(newState)
		newEnemy:play()

		-- print("New state: ", newState)
	end

    function newEnemy:move( dir )
		if state == "move" then return end

		setState("move")

		self:setLinearVelocity(lookDir * speed, 0)
    end

    function newEnemy:attack()
	end


    function newEnemy:cast()
    end


    -- Päivitetään vihollisen logiikkaa joka frame
	function newEnemy:enterFrame( event )
		local floorRay = raycast.newRay( self, "platform")
		local attackRay = raycast.newRay( self, "attack")
		local wallRay = raycast.newRay( self, "wall")

		if not floorRay or wallRay then
			if state ~= "idle" then
				setState("idle")

				self:setLinearVelocity(0, 0)


				-- Delay before turning around after near edge
				timer.performWithDelay( 300, function ()
					self.xScale = -self.xScale
					lookDir = self.xScale == 0.5 and 1 or -1

					self.lookDir = lookDir

					-- Delay before starting to move again
					timer.performWithDelay( 200, function()
						self:move(lookDir)
					end )

				end )
			end
		end
	end

	-- setState("cast")
	-- setState("move")

	newEnemy:move(lookDir)

	Runtime:addEventListener( "enterFrame", newEnemy )
    return newEnemy
end


return enemy