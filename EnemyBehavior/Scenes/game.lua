
--
local composer = require( "composer" )
local controls = require( "scripts.controls" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------





-- local function debugPrint(...) -- howto: debugPrint("string", object)
--     local args = {...}
--     local output = ""
--     for i = 1, #args do
--         output = output .. tostring(args[i]) .. "\t"
--     end
--     print("[DEBUG]", output)
-- end
-----------------------------------------------------------------------------------

local player, enemy
local _timer = timer.performWithDelay
local _random = math.random
local update
local mouseX, mouseY

local onKey
local physics = require("physics")
physics.start()

local characterSheetOptions = {
    width = 64,
    height = 64,
    numFrames = 72,
}
----------------------------------DEBUGGING-------------------------------------------------
local debugKeys = {
    space = { action = function() print( "..." )   end },
    left = { action = function() player:handleAnimation("attack", "left")   end },
}

local characterSheet = graphics.newImageSheet( "Images/player/character.png", characterSheetOptions )

local function reverseFrames(startFrame, count)
    local frames = {}
    for i = startFrame + count - 1, startFrame, -1 do
        frames[#frames+1] = i
    end
    return frames
end

local animateTime = 800
local sequences = {
-------------------------------IDLE-----------------------------------------------
    {name = "idledown", start = 1, count = 1, time = animateTime},  -- Placeholder to avoid errors
    {name = "idleleft", start = 2, count = 1, time = animateTime},
    {name = "idleright", start = 3, count = 1, time = animateTime},
    {name = "idleup", start = 4, count = 1, time = animateTime},

-------------------------------WALKING-----------------------------------------------
    {name = "walkdown", start = 9, count = 6, time = animateTime},
    {name = "walkleft", start = 17, count = 6, time = animateTime},
    {name = "walkright", start = 25, count = 6, time = animateTime},
    {name = "walkup", start = 33, count = 6, time = animateTime},

-------------------------------ATTACKING-----------------------------------------------
    {name = "attackdown", start = 41, count = 8, time = animateTime, loopCount = 1},
    {name = "attackleft", start = 49, count = 8, time = animateTime, loopCount = 1},
    {name = "attackright", start = 57, count = 8, time = animateTime, loopCount = 1},
    {name = "attackup", start = 65, count = 8, time = animateTime, loopCount = 1},

-------------------------------ATTACKING-REVERSED---------------------------------------
    {name = "attackdownReversed", frames = reverseFrames(41, 8), time = animateTime},
    -- {name = "attackleft", start = 49, count = 8, time = animateTime},
    -- {name = "attackright", start = 57, count = 8, time = animateTime},
    -- {name = "attackup", start = 65, count = 8, time = animateTime},
}



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	if event.params then table.print( event.params ) end --Check for params

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

end


local function getAngleBetween(params)
    local dx = params.targetOther.x - params.targetSelf.x
    local dy = params.targetOther.y - params.targetSelf.y

    local angle
    if params.returnDeg then
        angle = math.deg(math.atan2(dy, dx))

        if angle < 0 then
            angle = angle --+ 360
        end
    else
        angle = math.atan2(dy, dx)
    end

    return angle
end

local function newCharacter(isPlayer, x, y)
    local body = display.newSprite( characterSheet, sequences )
    body:setSequence("idledown"); body:play()
    body.x, body.y = x, y
    body.xScale, body.yScale = 3,3

    physics.addBody( body, "dynamic", {isSensor = true or false} )
    body.gravityScale = 0

    body.hp = 100
    body.maxHp = 100
    body.attackDistance = 100
    body.rangedDistance = 150
    body.speed = 300
    body.isSencor = true
    body.id = isPlayer and "player" or "enemy"
    body.lastDirection = "down" --Not yet is use
    body.isAttacking = false

--------------------Functions for both player and enemy-------------------------------------
    -- Animaatio täytyy ohjata
    function body.handleAnimation(self, phase, direction)
        if not phase or not direction then return end

        local action = phase .. direction

        if self.isAttacking then return true end

        if phase == "attack" then
            player:setLinearVelocity(0)
            self.isAttacking = true
            self:attackMelee(direction)
            _timer(animateTime, function()
                self.isAttacking = false

                -- Pakotetaan idle animaatio jos pelaaja ei hyökkää tai liiku
                if not self.isAttacking or phase ~= "move" then
                        self:setSequence("idle" .. direction)
                end
            end)
        end



        self:setSequence( action )
        -- print(phase, direction, action)
        self:play()
        return true
    end

    function body:attackRanged()
        print("attackRanged")
        return true
    end

    function body:attackMelee(direction)
        print( self.id, "Attacks melee in dir: " .. direction )
    end

    function body:hold()
        self:setLinearVelocity(0, 0)
    end

    if not body.isPlayer then
        body.moveStatus = "approach"  --approach, retreat,
        body.safeDistance = 200
        body.lastActionTime = {}
        body.nextAction = nil
        body.globalCooldown = 2
        body.lastGlobalUsed = 0
        body.nextAction = nil


        -- Distance / angle helpers
        function body:getTargetDistance(target)
            local dx = target.x - self.x
            local dy = target.y - self.y
            return math.sqrt(dx*dx + dy*dy)
        end

        function body:handleMovement( status )
            local distance = self:getTargetDistance(player) --Distance to player
            local toX, toY = getAngleBetween({ targetSelf = self, targetOther = player })    --Direction to player

            if status == "approach" then
                if distance < self.attackDistance then self:hold() return false end --close enought, no need to move
                self:setLinearVelocity(toX * self.speed, toY * self.speed)

                return true

            elseif status == "retreat" then
                if distance > self.safeDistance then self:hold() return false end -- already safe

                -- add slight random variance to avoid perfectly straight line
                local variance = 2  -- tweak this number for more/less randomness
                local randAngle = math.random() * variance - (variance / 2)  -- random between -variance/2 and +variance/2
                local cosVar = math.cos(randAngle)
                local sinVar = math.sin(randAngle)

                -- rotate vector slightly
                local finalX = -toX * cosVar - -toY * sinVar
                local finalY = -toX * sinVar + -toY * cosVar

                self:setLinearVelocity(finalX * self.speed, finalY * self.attack)
                return true
            end
        end
    end
    return body
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then

        player = newCharacter(true,  display.contentCenterX, display.contentCenterY )
        -- enemy = newCharacter(false)

        local function update()
            -- enemy:handleAction()
        end

        -- Mouse movement handler
        local function updateMouse(event)
            mouseX, mouseY = event.x, event.y
            if event.isPrimaryButtonDown then
                local angle = getAngleBetween({ targetSelf = player, targetOther = {x=mouseX, y=mouseY}, returnDeg=true })

                local attackDirection
                if ( -135 >= angle or angle > 135 ) then
                    attackDirection = "left"
                elseif ( -45 < angle and angle <= 45 ) then
                    attackDirection = "right"
                elseif ( -135 < angle and angle <= -45 ) then
                    attackDirection = "up"
                elseif ( 135 >= angle and angle > 45 ) then
                    attackDirection = "down"
                end

                if attackDirection then
                    player:handleAnimation("attack", attackDirection)
                end
            end
        end

        local function onKey(event)
            if event.phase == "down" and debugKeys[event.keyName] then
                local action = debugKeys[event.keyName].action

                if action then
                    action()
                end
            end
        end

        controls.start(player)

        Runtime:addEventListener("key", onKey)
        Runtime:addEventListener("mouse", updateMouse)
        Runtime:addEventListener("enterFrame", update)
	end
end

-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end

-- ------------------------------Scene event function listeners-------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

----------------------------BACKUP SECTION-------------------------------------------------------
--[[
function body:canPerform(stateName)
            local state = self.states[stateName]
            local now = system.getTimer() / 1000

            -- check state cooldown
            local last = self.lastActionTime[stateName] or 0
            local okState = (now - last) >= (state.cooldown or 0)

            -- check global cooldown
            local lastGlobal = self.lastGlobalUsed or 0
            -- local okGlobal = (now - lastGlobal) >= (self.globalCooldown or 0)

            return okState --and okGlobal
        end

        function body:performState(stateName)
            if not self:canPerform(stateName) then
                return false
            end

            local state = self.states[stateName]
            local result = state.action(self)

            self.lastActionTime[stateName] = system.getTimer() / 1000
            -- self.lastGlobalUsed = self.lastActionTime[stateName]
            return result
        end

        function body:handleAction()
            if not self.nextAction then
                local r = _random()
                -- self.nextAction = r <= 0.5 and "meleeAttack" or "rangedAttack"
                self.nextAction = "meleeAttack"
                -- self.nextAction = "rangedAttack"
            end

            local state = self.states[self.nextAction]

            -- Check if positional requirements are met for the action
            if state.precheck and not state.precheck(self) then
                return -- Still moving into position
            end

            -- Check if performed action return true (action complete)
            if self:performState(self.nextAction) then
                Runtime:removeEventListener("enterFrame", update)
                self.nextAction = nil
            end
        end

         -- State table
    body.states = {
        meleeAttack = {
            action = body.attackMelee,
            cooldown = 1.5,
            precheck = function(self) return not body.handleMovement(body, "approach") end -- returns false if still approaching
        },

        rangedAttack = {
            action = body.attackRanged,
            cooldown = 2.0,
            precheck = function(self) return not body.handleMovement(body, "retreat") end-- returns false if still retreating
        },

    --     heal = { action = enemy.heal, cooldown = 1.0 },
    }
--]]