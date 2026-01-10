local effects = require("data.effects")
local emitterModule = require("scripts.emitter")
local projectileModule = require("scripts.projectileModule")
local json = require( "json" )


local wizard = {}

local sheet = graphics.newImageSheet( "assets/images/characters/wizard.png",
	{
		width = 64,
		height = 64,
		numFrames = 27
	} )

local animateTime = 600
local animation = {
	{ name = "idle",   frames= { 1 }, time = animateTime, loopCount = 0 },
	{ name = "move",   start = 2,  count = 8, time = animateTime, loopCount = 0 },
	{ name = "cast", start = 10, count = 7, time = animateTime, loopCount = 3 },
	{ name = "attack", frames= { 23 }, time = animateTime, loopCount = 1 },
}

local rayConfig = {
	rayDistance = 1,
	rayOffsetX = 0.05,
	rayOffsetY = 4,
	rayDropDistance = 4,

	attackRange = 100,

	debugLineWidth = 2,
	-- debugMode = true
}

local states = {
	idle = "idle",
	moving = "moving",
	attacking = "attacking",
}

local function newRay( params )
	local rayType   = params.rayType
    local startX    = params.startX
    local startY    = params.startY
    local endX      = params.endX
    local endY      = params.endY
    local mode      = params.mode
    local character = params.character

	local hits = physics.rayCast(startX, startY, endX, endY, mode)

	-- Piirretään debug viiva, jotta näemme raycast-säteen pelissä.
	if rayConfig.debugMode then
		local rayColor = hits and { 1,0,0 } or { 0,1,0 }
		display.remove(character.debugLine)
		character.debugLine = display.newLine(character._parent, startX, startY, endX, endY)
		character.debugLine:setStrokeColor( unpack(rayColor) )
		character.debugLine.strokeWidth = rayConfig.debugLineWidth
	end

	-- Katsotaan osuiko säde toivottuun kohteeseen.
	if hits then
	    for i = 1, #hits do
	        local hitObject = hits[i].object

	        -- Phase 1: must match ray type
	        if hitObject.id == rayType then

	            -- Phase 2: platform-specific rule
	            if rayType == "platform" then
	                if not hitObject.isStairs then
	                    return true
	                end
	            else
	                return true
	            end

	        end
	    end
	end
	return false
end


local function removeObj( targetObj )
	if targetObj.id then
		-- print( "removing object: ", targetObj.id )
		targetObj:removeSelf(); targetObj = nil
	else
		print("invalid id")
	end
end


local function checkGroundAhead( character, direction )

	-- Viiva alkaa hahmon edestä tai takaa riippuen suunnasta.
	local startX = character.x + (character.width*rayConfig.rayOffsetX + rayConfig.rayDistance) * direction
	local startY = character.y + character.height*0.2 - rayConfig.rayOffsetY

	-- Viiva piirretään suoraan alaspäin.
	local endX = startX
	local endY = startY + rayConfig.rayDropDistance

	-- Suoritetaan raycast, eli katsotaan osukko viiva fysiikkakehoihin.
	local foundPlatform = newRay({
    rayType = "platform",
    startX = startX,
    startY = startY,
    endX = endX,
    endY = endY,
    mode = "sorted",
    character = character
})

	return foundPlatform
end

local function checkPlayerinRange( character, direction )

	-- Viiva alkaa hahmon edestä tai takaa riippuen suunnasta.
	local startX = character.x
	local startY = character.y

	-- Viiva piirretään suoraan alaspäin.
	local endX = startX + ( rayConfig.attackRange * direction )
	local endY = startY

	-- Suoritetaan raycast, eli katsotaan osukko viiva fysiikkakehoihin.
	local inRange = newRay({
    rayType = "player",
    startX = startX,
    startY = startY,
    endX = endX,
    endY = endY,
    mode = "sorted",
    character = character
})

	return inRange
end

function wizard.new(parent, reference)
	local x, y
	local scale = 0.5
	local state = "idle" -- idle | move | attack | dead


	if reference then
		x, y = reference.x, reference.y
		display.remove(reference)
	else
        return false
	end

    local body = display.newSprite(sheet, animation)
    body.x, body.y, body.xScale, body.yScale = x, y, scale, scale
    body.id = "wizard"
    parent:insert( body )
    body._parent = parent

	body:setSequence("idle")
	body.state = states.idle
	physics.addBody(body, "dynamic", {
		radius = body.width * 0.15,
		friction = 0.3,
		density = 0.5,
		bounce = 0
	} )

	body.lookDir = 1 -- -1 = left, 1 = right
	body.isFixedRotation = true
	body.speed = 60
	body.currentHP = 2
	body.maxHP = 2

	local cooldown, lastAttack = 1000, nil

--------------------AI Funktiot-----------------------------
	local function setState(newState)
	    if body.state == newState then return false end
	    body.state = newState

	    if newState == states.idle or newState == states.attacking then
	        body:setLinearVelocity( 0, 0 )
	    end

	    return true
	end


    function body:move( prevState )
		self:setLinearVelocity( self.xScale * self.speed, 0 )

		if body.state ~= prevState then --Ladataan liikeanimaatio
			body:setSequence("move")
			body:play()
		end

    end

	local attackTimer = nil
    function body:attack()
	    if attackTimer then return end  -- HARD guard

	    body:setSequence("attack")
	    body:play()

	    local x = self.x + self.width/2.6 * self.xScale
	    local y = self.y + 5

	    local effectIn = emitterModule.new(body._parent, x, y, "attackEffectIn")

	    local duration = (effectIn.duration * 2.3) * 1000

	    attackTimer = timer.performWithDelay(duration, function()
	        removeObj(effectIn)

	        local effectOut = emitterModule.new(body._parent, x, y, "attackEffectOut")
	        local projectile = projectileModule.new(body, x, y, removeObj)
			projectile.angle = body.lookDir == -1 and 0 or 180

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


    function body:cast()
    end


    -- Päivitetään vihollisen logiikkaa joka frame
    function body.update()
		body.lookDir = (body.xScale * 2)
		if body.state == states.attacking then return end

		if lastAttack then
			if ( system.getTimer() - lastAttack ) < cooldown then
				return
			end
		end

		-- Otetaan tämänhetkinen state talteen ennen mahdollisia muutoksia
		local prevState = body.state
        local playerInRange = checkPlayerinRange( body, body.xScale )

		if playerInRange then
		    if setState(states.attacking) then
		        body:attack()
		    end
		    return
		end

        local platformAhead = checkGroundAhead( body, body.xScale )

		if not platformAhead then
			setState( states.idle )
			-- TODO: Lisää viive
			body.xScale = ( body.xScale * -1)
		else
			setState( states.moving )
		end

		body:move( prevState )
	end


    Runtime:addEventListener( "enterFrame", body.update )
    return body
end


return wizard