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
	        box = { halfWidth = 4, halfHeight = 8, y = -10, x = 0 },
			userData = "body",
			density = 50
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

	local onCooldown = false
	local cdList = { }
	-- local startTime, duration
	-- local cdRuntime
	-- local cdCallback

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
		local newProjectile = projectileModule:new( self, player )
	end

	local function hasTimePassed(startTime, duration)
		return ( system.getTimer() - startTime ) >= duration
	end

	local function hold( duration, callback )
		if duration and callback then
			onCooldown = true

			local newTable = {
				startTime = system.getTimer(),
				duration = duration,
				callback = callback
			}

			table.insert(cdList, newTable)
		end

		if onCooldown then
			for i = #cdList, 1, -1 do
				local t = cdList[i]

				local timePassed = hasTimePassed(t.startTime, t.duration)

				if timePassed then
					t.callback()
					table.remove(cdList, i)
				end
			end

			if #cdList == 0 then
				onCooldown = false
			end
		end

	end


    -- Päivitetään vihollisen logiikkaa joka frame
	local function update( event )
		local self = newEnemy

		local floorAhead = raycast.newRay( self, "platform")
		local playerSeen, ref = raycast.newRay( self, "attack")
		local wallAhead = raycast.newRay( self, "wall")
		local mustTurn = not floorAhead or wallAhead

		local timeBeforeTurn = devMode and 200 or 1000
		local timeBeforeMove = devMode and 200 or 400


		if onCooldown then
			hold()
			return
		end

		if state == "idle" and not mustTurn then
			self:move()
		end


		if playerSeen then
			if state ~= "attack" then
				setState("attack")
				self:setLinearVelocity(0, 0)

				if not ref or ref.id ~= "player" then
					print("WARNING: Player reference not given")
				end

				player = ref

				newEnemy:attack()
			end

		else
			if mustTurn then
				if state ~= "idle" then
					setState("idle")

					self:setLinearVelocity(0, 0)

					-- Delay before turning around after near edge
					hold( timeBeforeTurn, function ()
						self.xScale = -self.xScale
						lookDir = self.xScale == 0.5 and 1 or -1

						self.lookDir = lookDir
					end )

					hold( ( timeBeforeTurn + timeBeforeMove ), function() self:move() end)
				end
			end
		end
	end

	local function spriteListener(event)
		local p = event.phase
		if p == "ended" then print( event.target.sequence ) end

		if p == "ended" and event.target.sequence == "attackReverse" then
			setState("idle")
		end

		if p == "ended" and state == "attack" then

			hold(300, function()
				setState("attackReverse")
			end )

			-- Hold attack animation for a breaf moment
			hold(1800, function() return end )
		end
	end

	newEnemy:addEventListener("sprite", spriteListener)
	Runtime:addEventListener( "enterFrame", update )

	newEnemy:move()

	return newEnemy
end


return enemy