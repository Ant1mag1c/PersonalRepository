local effects = require("data.effects")
local emitterModule = require("scripts.emitter")
local projectileModule = require("scripts.projectileModule")
local raycastModule = require("scripts.raycast")
local animation = require("data.animation")
local player

local characterData = {

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

local enemy = {}


local sequence = animation.sequences
local sheet = graphics.newImageSheet(
	animation.sheets["enemy"],
	animation.data["enemy"]
)



function enemy.new( parent, reference )
	local x, y = reference.x, reference.y

	if reference then
		characterData.x, characterData.y = reference.x, reference.y
		display.remove(reference)
	else
        return false
	end

    local newEnemy = display.newSprite(sheet, sequence)
	parent:insert( newEnemy )

	newEnemy.x, newEnemy.y = x, y
	newEnemy.xScale, newEnemy.yScale = 0.5, 0.5
	newEnemy.anchorY = 0.8


	local bodies = {
		{
	        box = { halfWidth = 6, halfHeight = 8, y = -10, x = 0 },
			userData = "body",
			density = 8
	    },

		{
			radius = 2,
			userData = "foot"
	    }
	}

	physics.addBody( newEnemy, "dynamic", bodies[1], bodies[2])
	newEnemy.isFixedRotation = true

	local state = "idle"


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
	end

    function newEnemy:move( )
    end

    function newEnemy:attack()
	end


    function newEnemy:cast()
    end


    -- Päivitetään vihollisen logiikkaa joka frame
	function newEnemy:enterFrame( event )
		-- if ( system.getTimer() - self.lastAttackTime ) < self.attackCooldown then return end
	end

	-- setState("cast")
	-- setState("move")
	setState("idle")

	Runtime:addEventListener( "enterFrame", newEnemy )
    return newEnemy
end


return enemy