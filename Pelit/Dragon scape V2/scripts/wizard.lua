local effects = require("data.effects")
local emitterModule = require("scripts.emitter")
local projectileModule = require("scripts.projectileModule")
local raycast = require("scripts.raycast")
local animation = require("data.animation")
local player

local devMode = true

if devMode then print("enemy debug true") end

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
	        box = { halfWidth = 8, halfHeight = 8, y = -10, x = 0 },
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
	local onCooldown = false



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

    function newEnemy:move()
		if state == "move" then return end

		setState("move")

		self:setLinearVelocity(lookDir * speed, 0)
    end

    function newEnemy:attack()
	end


    -- Päivitetään vihollisen logiikkaa joka frame
	local function update( event )
		local self = newEnemy

		if onCooldown then return end

		local floorAhead = raycast.newRay( self, "platform")
		local playerSeen = raycast.newRay( self, "attack")
		local wallAhead = raycast.newRay( self, "wall")


		local mustTurn = not floorAhead or wallAhead

		local delayTurn = devMode and 200 or 500
		local delayMove = devMode and 200 or 400

		if state == "idle" and not mustTurn then
			self:move()
		end


		if playerSeen then
			if state ~= "attack" then
				setState("attack")

				self:setLinearVelocity(0, 0)

			end

		else
			if mustTurn then
				if state ~= "idle" then
					setState("idle")

					self:setLinearVelocity(0, 0)

					-- Delay before turning around after near edge
					timer.performWithDelay( delayTurn, function ()
						self.xScale = -self.xScale
						lookDir = self.xScale == 0.5 and 1 or -1

						self.lookDir = lookDir

						-- Delay before starting to move again
						timer.performWithDelay( delayMove, function()
							self:move(lookDir)
						end )

					end )
				end
			end
		end
	end

	local function spriteListener(event)
		if event.phase == "ended" and state == "attack" then
			onCooldown = true

			-- Hold attack animation for a breaf moment
			timer.performWithDelay( 300, function() setState( "idle" ) end )

			-- Allow enemy to performs next action
			timer.performWithDelay( 1800, function() onCooldown = false end )

		end
	end

	newEnemy:addEventListener("sprite", spriteListener)
	Runtime:addEventListener( "enterFrame", update )

	newEnemy:move()

	return newEnemy
end


return enemy