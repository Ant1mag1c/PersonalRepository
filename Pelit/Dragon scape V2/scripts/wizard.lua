local wizard = {}

local sheet = graphics.newImageSheet( "assets/images/characters/wizard.png",
	{
		width = 64,
		height = 64,
		numFrames = 27
	} )

local animateTime = 600
local animation = {
	{ name = "idle",   start = 1,  count = 1, time = animateTime, loopCount = 0 },
	{ name = "move",   start = 2,  count = 8, time = animateTime, loopCount = 0 },
	{ name = "cast", start = 10, count = 7, time = animateTime, loopCount = 3 },
	{ name = "attack", start = 19, count = 8, time = animateTime, loopCount = 0 },
}

local rayConfig = {
	rayDistance = 1,
	rayOffsetX = 0.05,
	rayOffsetY = 4,
	rayDropDistance = 4,

	debugLineWidth = 2,
	debugMode = true
}

local aiState = {
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
		display.remove(character.debugLine)
		character.debugLine = display.newLine(character._parent, startX, startY, endX, endY)
		character.debugLine:setStrokeColor( 1, 0, 0, 0.9 )
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

local function checkGroundAhead( character, direction )
	local foundPlatform = false

	-- Viiva alkaa hahmon edestä tai takaa riippuen suunnasta.
	local startX = character.x + (character.width*rayConfig.rayOffsetX + rayConfig.rayDistance) * direction
	local startY = character.y + character.height*0.2 - rayConfig.rayOffsetY

	-- Viiva piirretään suoraan alaspäin.
	local endX = startX
	local endY = startY + rayConfig.rayDropDistance

	-- Suoritetaan raycast, eli katsotaan osukko viiva fysiikkakehoihin.
foundPlatform = newRay({
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

function wizard.new(parent, reference)
	local x, y
	local scale = 0.5

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
	body.state = aiState.idle
	physics.addBody(body, "dynamic", {
		radius = body.width * 0.15,
		friction = 0.3,
		density = 0.5,
		bounce = 0
	} )

	body.isFixedRotation = true

------------------------------------------------------------
	local state = "idle" -- idle | move | attack | dead
	local lookDir = 1   -- -1 = left, 1 = right

	body.speed = 60
	body.currentHP = 2
	body.maxHP = 2

--------------------AI Funktiot-----------------------------
	local function setState(newState)
		if state == newState then return end
		state = newState

		if state == "idle" then
			body:setSequence("idle")
			body:play()

		elseif state == "move" then
			body:setSequence("move")
			body:play()

		elseif state == "attack" then
			body:setSequence("attack")
			body:play()
		end
	end

    function body:move()
		local vx, _ = self:getLinearVelocity()

		-- if vx == 0 then	--Hahmo on pysähtynyt rayCastin toimesta
			self:setLinearVelocity( self.xScale * self.speed, 0 )
		-- end
		print( vx )

    end

    function body:attack()
    end

    function body:cast()
    end


    -- Päivitetään vihollisen logiikkaa joka frame
    function body.update()
        local platformAhead = checkGroundAhead( body, body.xScale )

		if not platformAhead then
			body.state = aiState.idle
		else
			if body.state == aiState.idle then
				body.state = aiState.moving
			end
		end

		if body.state == aiState.idle or body.state == aiState.attacking then
			body:setLinearVelocity( 0, 0 )

			if body.state == aiState.idle then
				-- TODO: Lisää viive
				body.xScale = ( body.xScale * -1) --Hahmo kääntyy
			end
		end

		body:move()
	end

    Runtime:addEventListener( "enterFrame", body.update )
    return body
end


return wizard