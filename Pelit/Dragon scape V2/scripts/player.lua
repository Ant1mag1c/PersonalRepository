local player = {}

local physics = require("physics")

----------------------------------------------------------------------------------

local sfxJump = audio.loadSound("assets/audio/sfx/jump.wav")
local sfxHurt = audio.loadSound("assets/audio/sfx/hurt.wav")

local sheet = graphics.newImageSheet(
	"assets/images/characters/player.png",
	{
		width = 64,
		height = 64,
		numFrames = 36
	}
)

local animation = {
	{ name = "idle",   start = 1,  count = 1, time = 250, loopCount = 0 },
	{ name = "move",   start = 1,  count = 2, time = 250, loopCount = 0 },
	{ name = "attack", start = 28, count = 6, time = 800, loopCount = 1 }
}

----------------------------------------------------------------------------------

function player.new(parent, reference)
	local x, y
	local scale = 0.5

	if reference then
		x, y = reference.x, reference.y
		display.remove(reference)
	else
		local spawn = 100
		x, y = 100, spawn
	end

	local newPlayer = display.newSprite(sheet, animation)
	newPlayer.x, newPlayer.y = x, y
	newPlayer.xScale, newPlayer.yScale = scale, scale
	newPlayer.id = "player"
	parent:insert(newPlayer)

	physics.addBody(newPlayer, "dynamic", {
		radius = newPlayer.width * 0.15,
		friction = 0.3,
		density = 0.5,
		bounce = 0
	})

	newPlayer.isFixedRotation = true

	----------------------------------------------------------------------------------
	-- INTERNAL STATE
	----------------------------------------------------------------------------------

	local state = "idle" -- idle | move | attack | dead
	local lookDir = -1   -- -1 = left, 1 = right

	local jumpCount = 0
	local maxJumpCount = 1
	local jumpForce = -0.65
	local ropeTouchCount = 0
	local onStairs = false


	----------------------------------------------------------------------------------
	-- PLAYER STATS
	----------------------------------------------------------------------------------

	newPlayer.moveSpeed = 100
	newPlayer.currentHP = 2
	newPlayer.maxHP = 2
	newPlayer.isDead = false
	newPlayer.isImmortal = false
	newPlayer.timerImmortal = nil

	local immortalTime = 500

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
		end
	end

	----------------------------------------------------------------------------------
	-- DAMAGE
	----------------------------------------------------------------------------------

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
		local lookNow = vx == 1 and 1 or vx == -1 and -1 or nil

		if state == "attack" or state == "dead" then
			local _, currentVy = self:getLinearVelocity()
			self:setLinearVelocity(0, currentVy)
			return
		end

		-- Jos pelaaja kääntyy
		if lookNow and lookNow ~= lookDir then
			lookDir = lookNow
			newPlayer.xScale = -lookNow * scale
		end


		if vx == 0 then
			setState("idle")
		else
			setState("move")
		end

		local currentVx, currentVy = self:getLinearVelocity()
		local touchingRope = ropeTouchCount > 0

		-- Rope logic
		if touchingRope then
			if vy == 0 then
				currentVy = 0
			else
				currentVy = vy * self.moveSpeed
			end
		end

		self:setLinearVelocity(vx * self.moveSpeed, currentVy)
	end

	function newPlayer:touchRope(didTouchBegin)
		if didTouchBegin then
			ropeTouchCount = ropeTouchCount + 1
		else
			ropeTouchCount = math.max(ropeTouchCount - 1, 0)
		end

		-- Disable gravity while on rope
		if ropeTouchCount > 0 then
			self.gravityScale = 0
			self:setLinearVelocity(0, 0)
		else
			self.gravityScale = 1
		end
	end

	function newPlayer:attack(dir)
		if state == "attack" or state == "dead" then return end

		lookDir = dir
		self.xScale = -dir * scale
		setState("attack")
	end

	----------------------------------------------------------------------------------
	-- JUMP
	----------------------------------------------------------------------------------

	function newPlayer:jump(didJumpBegin)
		if state == "dead" then return end
		if not didJumpBegin then return end
		if jumpCount >= maxJumpCount then return end

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
