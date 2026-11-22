local player = {}

local physics = require("physics")
local sfxJump = audio.loadSound("assets/audio/sfx/jump.wav")
local sfxHurt = audio.loadSound("assets/audio/sfx/hurt.wav")

local animation = require("data.animation")
local sequence = animation.sequences["player"]

local sheet = graphics.newImageSheet(
	animation.sheets["player"],
	animation.data["player"]
)



function player.new(parent, reference)
	local x, y
	local scale = 0.5

	if reference then
		x, y = reference.x, reference.y
		display.remove(reference)
	else
		x, y = 100,150
	end

	local newPlayer = display.newSprite(sheet, sequence)
	newPlayer.x, newPlayer.y = x, y
	newPlayer.anchorY, newPlayer.anchorX = 0.75, 0.55
	newPlayer.xScale, newPlayer.yScale = scale, scale
	newPlayer.id = "player"

	parent:insert(newPlayer)

	local bodies = {
		{
	        box = { halfWidth = 3, halfHeight = 9, y = -8, x = 0 },
			userData = "body"
	    },

		{
			radius = 2,
			userData = "foot"
	    }
	}

	physics.addBody(newPlayer, "dynamic", bodies[1], bodies[2] )
	newPlayer.isFixedRotation = true

	newPlayer.moveSpeed = 60
	newPlayer.currentHP = 2
	newPlayer.maxHP = 2
	newPlayer.isDead = false

	newPlayer.ropeTouched = false
	newPlayer.isClimbing = false
	newPlayer.onAir = false
	newPlayer.onGround = false

	newPlayer.timerImmortal = nil
	newPlayer.isImmortal = false
	newPlayer.isInvisible = false

	local state = "idle" -- idle | move | attack | dead
	local lookDir = -1   -- -1 = left, 1 = right

	local jumpCount = 0
	local maxJumpCount = 1
	local jumpForce = -0.0052
	local ropeTouchCount = 0

	local lastAttack = 0
	local immortalTime = 500
	local attackCooldown = 600


	if newPlayer.isImmortal or newPlayer.isInvisible then print( "Player debug on" ) end

	local function setState(newState)
		if state == newState then return end
		state = newState

		if state == "idle" then
			newPlayer:setSequence("idle")
			newPlayer:play()

		elseif state == "move" then
			newPlayer:setSequence("move")
			newPlayer:play()

		elseif state == "attack" then
			newPlayer:setSequence("attack")
			newPlayer:play()

		elseif state == "climb" then
			newPlayer:setSequence("climb")
			newPlayer:play()

		elseif state == "climbIdle" then
			newPlayer:setSequence("climbIdle")
			newPlayer:play()

		elseif state == "jump" then
			newPlayer:setSequence("jump")
			newPlayer:play()
		end
	end

	function newPlayer:takeDamage(amount)
		if self.isDead or self.isImmortal then return end

		self.currentHP = math.max(self.currentHP - amount, 0)
		audio.play(sfxHurt, { channel = audio.findFreeChannel(2) })

		self.isImmortal = true
		self.alpha = 0.5
		transition.blink(self, { time = immortalTime })

		self.timerImmortal = timer.performWithDelay(immortalTime, function()
			self.isImmortal = false
			self.alpha = 1
			transition.cancel(self)
		end)

		if self.currentHP <= 0 then
			self.isDead = true
			state = "dead"
			self.isFixedRotation = false
			self:setLinearVelocity(math.random(-50, 50), -200)
			self:applyAngularImpulse(math.random(-25, 25))
		end
	end

	function newPlayer:move(vx, vy)
		local onAir = jumpCount == maxJumpCount
		local lookNow = vx == 1 and 1 or vx == -1 and -1 or nil
		local _, currentVy = self:getLinearVelocity()
		local touchingRope = ropeTouchCount > 0
		local jumpReset = jumpCount ~= maxJumpCount

		local onGround = self.onGround
		local touchedRope = self.touchedRope
		local climbing = self.isClimbing

		if state == "attack" or state == "dead" then
			local _, currentVy = self:getLinearVelocity()
			self:setLinearVelocity(0, currentVy)
			return
		end

		-- Jos pelaaja kääntyy
		if lookNow and lookNow ~= lookDir and not self.isClimbing then
			lookDir = lookNow
			newPlayer.xScale = -lookNow * scale
		end

		-- Animation handling
		if onAir then setState("jump") end

		if onAir and currentVy == 0 then
			setState("idle")
			self:resetJumpCount()
		end
		if not climbing and not onAir then
			if vx == 0 then
				setState("idle")
			else
				 setState("move")

			end
		end

		-- Rope logic
		if touchingRope then
			if vy == 0 then
				if climbing then
					currentVy = 0
					self:setLinearVelocity(0, 0)
					self.gravityScale = 0
					setState("climbIdle")
				end

			elseif vy ~= 0 then
				if not touchedRope then return end
				if vy == 1 and onGround then self.isClimbing = false return end
				self.isClimbing = true

				setState("climb")
				self.x = touchedRope.x

				currentVy = vy * self.moveSpeed
			end
		end

		if climbing and not jumpReset then self:resetJumpCount() end
		if vx ~= 0 and climbing then vx = 0 end


		self.onAir = onAir
		self:setLinearVelocity(vx * self.moveSpeed, currentVy)

		-- print("onAir", onAir, "onGround", onGround, "touchedRope", touchedRope)
	end

	function newPlayer:touchRope(didTouchBegin)
		if didTouchBegin then
			ropeTouchCount = ropeTouchCount + 1

		else
			ropeTouchCount = math.max(ropeTouchCount - 1, 0)
		end

		if ropeTouchCount > 0 then
			self.ropeTouched = true
		else
			self.ropeTouched = false
			self.isClimbing = false
			self.gravityScale = 1
		end



		-- print("RopeTouched/Climbing/TX: ", self.ropeTouched, self.isClimbing)
	end

	function newPlayer:attack(dir)
		if state == "attack" or state == "dead" then return end

		if ( system.getTimer() - lastAttack ) < attackCooldown then
			return
		end

		lastAttack = system.getTimer()

		setState("attack")

		lookDir = dir
		self.xScale = -dir * scale
	end

	----------------------------------------------------------------------------------
	-- JUMP
	----------------------------------------------------------------------------------

	function newPlayer:jump(didJumpBegin)
    if state == "dead" then return end
    if not didJumpBegin then return end
	if jumpCount >= maxJumpCount then return end


	setState("jump")

	if self.isClimbing then
        self.isClimbing = false
        self.gravityScale = 1
        self:resetJumpCount()
    end



    jumpCount = jumpCount + 1


    audio.play(sfxJump, { channel = audio.findFreeChannel(2) })

    local vx, _ = self:getLinearVelocity()
    self:setLinearVelocity(vx, 0)
    self:applyLinearImpulse(0, jumpForce, self.x, self.y)
end

	function newPlayer:resetJumpCount()
		jumpCount = 0
	end

	----------------------------------------------------------------------------------
	-- SPRITE LISTENER
	----------------------------------------------------------------------------------

	local function spriteListener(event)
		if event.phase == "ended" and state == "attack" then
			setState("idle")
		end
	end

	newPlayer:addEventListener("sprite", spriteListener)

	----------------------------------------------------------------------------------
	-- CLEANUP
	----------------------------------------------------------------------------------

	function newPlayer:finalize()
		if self.timerImmortal then
			timer.cancel(self.timerImmortal)
			self.timerImmortal = nil
		end
		transition.cancel(self)
	end

	newPlayer:addEventListener("finalize")

	setState("idle")
	return newPlayer
end

return player
