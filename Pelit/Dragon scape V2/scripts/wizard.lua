local effects = require("data.effects")
local emitterModule = require("scripts.emitter")
local projectileModule = require("scripts.projectileModule")
local raycastModule = require("scripts.raycast")
local json = require( "json" )
local player

local characterData = {
	id = "enemy",
	x = 0,
	y = 0,
	anchorY = 0.8,
	xScale = 0.5,
	yScale = 0.5,
	stateNow = "idle",
	prevState = "idle",
	lookDir = 1,
	speed = 60,
	currentHP = 2,
	maxHP = 2,
	attackCooldown = 1000,

	playerSeen = false,
	lastAttackTime = nil,
	attackTimer = nil,
	animateTime = 600,
	playerRef = nil,

	-- Helper functions
	loadAnim = function( self, sequence ) self:setSequence(sequence); self:play() end,
	removeObj = function( targetObj ) targetObj:removeSelf(); targetObj = nil end,
	setState = function(self, state) if self.stateNow ~= state then
        self.stateNow = state
		if state ~= "move" then self:setLinearVelocity( 0 ) end
        print("State changed to:", state)
    end

end


}

local wizard = {}

local sheet = graphics.newImageSheet( "assets/images/characters/wizard.png",
	{
		width = 64,
		height = 64,
		numFrames = 27
	}
)


local animation = {
	{ name = "idle",   frames= { 1 }, time = characterData.nimateTime, loopCount = 0 },
	{ name = "move",   start = 2,  count = 8, time = characterData.animateTime, loopCount = 0 },
	{ name = "cast", start = 10, count = 7, time = characterData.animateTime, loopCount = 3 },
	{ name = "attack", frames= { 23 }, time = characterData.animateTime, loopCount = 1 },
}


-- local function removeObj( targetObj )
-- 	if targetObj.id then
-- 		-- print( "removing object: ", targetObj.id )
-- 		targetObj:removeSelf(); targetObj = nil
-- 	else
-- 		print("invalid id")
-- 	end
-- end

function wizard.new(parent, reference, playerRef)
	if playerRef then characterData.playerRef = playerRef end

	if reference then
		characterData.x, characterData.y = reference.x, reference.y
		display.remove(reference)
	else
        return false
	end

    local wizard = display.newSprite(sheet, animation)
	parent:insert( wizard )
	wizard._parent = parent

	-- Noudetaan characterDatan sisältö ja liitetään ne objektiin
	for k, v in pairs(characterData) do
		wizard[k] = v
	end


	physics.addBody( wizard, "dynamic",
	    {
	        box = { halfWidth = 4, halfHeight = 8, y = -10, x = 0 },
			userData = "body"
	    },

	    {
	        radius = 3,
			userData = "foot"
	    }
	)
	wizard.isFixedRotation = true


    function wizard:move( prevState )
		wizard.lookDir = (wizard.xScale * 2)

		self:setLinearVelocity( self.xScale * self.speed, 0 )

		if wizard.state ~= prevState then --Ladataan liikeanimaatio
			wizard:setSequence("move")
			wizard:play()
		end

    end

    function wizard:attack()
	    if attackTimer then return end  -- HARD guard

	    wizard:setSequence("attack")
	    wizard:play()

	    local x = self.x + self.width/2.6 * self.xScale
	    local y = self.y + 5

	    local effectIn = emitterModule.new(wizard._parent, x, y, "attackEffectIn")

	    local duration = (effectIn.duration * 2.3) * 1000

	    attackTimer = timer.performWithDelay(duration, function()
	        removeObj(effectIn)

	        local effectOut = emitterModule.new(wizard._parent, x, y, "attackEffectOut")
	        local projectile = projectileModule.new(wizard, x, y, removeObj)
			projectile.angle = wizard.lookDir == -1 and 0 or 180

	        timer.performWithDelay(1000, function()
	            removeObj(effectOut)
	            attackTimer = nil
	            setState(states.idle)
				lastAttack = system.getTimer()

				self:setSequence("idle")
				self:play()
				print("idle")
	        end )
	    end)
	end


    function wizard:cast()
    end


    -- Päivitetään vihollisen logiikkaa joka frame
	function wizard:enterFrame( event )
	    -- print(self, event.time)
		local idle, move, attack = "idle", "move", "attack"

		if wizard.state == attack then return end

		-- Hyökkäyksen cooldown
		if self.lastAttackTime then
			if ( system.getTimer() - self.lastAttackTime ) < self.attackCooldown then return end
		end

		wizard.playerSeen = raycastModule.newRay( wizard, wizard.lookDir, "player")



	end

    -- function wizard.update()
	-- 	if wizard.state == states.attacking then return end

	-- 	-- if lastAttack then
	-- 	-- 	if ( system.getTimer() - lastAttack ) < cooldown then
	-- 	-- 		return
	-- 	-- 	end
	-- 	-- end

	-- 	-- -- Otetaan tämänhetkinen state talteen ennen mahdollisia muutoksia
	-- 	-- local prevState = wizard.state

	-- 	wizard.playerInRange = raycastModule.newRay( wizard, wizard.lookDir, "platform")

	-- 	-- if self.playerInRange then
	-- 	-- 	    if setState(states.attacking) then
	-- 	-- 		        wizard:attack()
	-- 	-- 		    end
	-- 	-- 		    return
	-- 	-- 		end

	-- 	wizard.playerSeen = raycastModule.newRay( wizard, wizard.lookDir, "player")
	-- 	-- 		if not self.platformAhead then
	-- 	-- 				setState( states.idle )
	-- 	-- 				-- TODO: Lisää viive
	-- 	-- 	wizard.xScale = ( wizard.xScale * -1)
	-- 	-- else
	-- 		-- setState( states.moving )
	-- 	-- end

	-- 	-- wizard:move( prevState )
	-- end

	-- timer.performWithDelay(500, function()	print( wizard.platformAhead ) end, 100 )


    Runtime:addEventListener( "enterFrame", wizard )
    return wizard
end


return wizard