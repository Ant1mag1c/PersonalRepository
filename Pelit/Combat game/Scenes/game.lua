
--
local composer = require( "composer" )
local controls = require( "scripts.controls" )
local physics = require("physics")
local timer = require("scripts.timer")
physics.start()

local scene = composer.newScene()

local random = math.random
local cos, sin = math.cos, math.sin

local player, enemy, swing
local mouseX, mouseY


-- Functions
local onKey, updateMouse, spriteListener, getDistance, getAngle, update

local defaultData =
{
    id = "player",
    hp = 100,
    isAlive = true,
    maxHp = 100,
    speed = 300,

    vx = 0,
    vy = 0,
    vxPrev = 0,
    vyPrev = 0,

    lookingDir = "down",
    lastDir = "down",
    sequence = "idledown",
    isAttacking = false,
    attackPower = nil,
    swingWidth = 60,
    meleeRange = 60,
    ai =
        {
            id = "enemy",
            moveStatus = "approach",  --approach, retreat,
            safeDistance = 200,
            lastActionTime = {},
            globalCooldown = 2,
            lastGlobalUsed = 0,
            nextAction = nil,
            rangedDistance = 150,
        }
}

local characterSheetOptions = {
    width = 64,
    height = 64,
    numFrames = 72,
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
    {name = "idledown", start = 1, count = 1, time = animateTime},  -- Placeholder to avoid errors
    {name = "idleleft", start = 2, count = 1, time = animateTime},
    {name = "idleright", start = 3, count = 1, time = animateTime},
    {name = "idleup", start = 4, count = 1, time = animateTime},

    {name = "walkdown", start = 9, count = 6, time = animateTime},
    {name = "walkleft", start = 17, count = 6, time = animateTime},
    {name = "walkright", start = 25, count = 6, time = animateTime},
    {name = "walkup", start = 33, count = 6, time = animateTime},

    {name = "attackdown", start = 41, count = 8, time = animateTime, loopCount = 1},
    {name = "attackleft", start = 49, count = 8, time = animateTime, loopCount = 1},
    {name = "attackright", start = 57, count = 8, time = animateTime, loopCount = 1},
    {name = "attackup", start = 65, count = 8, time = animateTime, loopCount = 1},

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

local function newCharacter(isPlayer, x, y)
    local isEnemy = not isPlayer
    local body = display.newSprite( characterSheet, sequences )
    body:setSequence("idledown"); body:play()
    body.x, body.y, body.xScale, body.yScale = x, y, 3, 3

    physics.addBody( body, "dynamic", {isSensor = true or false} )
    body.gravityScale = 0
    body.id = isPlayer and "player" or "enemy"

    for k, v in pairs(defaultData) do
        body[k] = v
    end

    local function spriteListener(event)
        if event.phase == "ended" and body.isAttacking then
            body.isAttacking = false
            body:setSequence("idle" .. body.lookingDir)
            body:play()
        end
    end

    function body.move( vx, vy )
        local directionChanged = body.lastDir ~= body.lookingDir
        local fromIdle = body.sequence == "idle" .. body.lastDir

        if vx ~= 0 or vy ~= 0 then
            -- Normalize diagonal movement
    		local len = math.sqrt(vx*vx + vy*vy)
    		vx, vy = (vx/len)*body.speed, (vy/len)*body.speed

            if directionChanged or fromIdle then
                body:setSequence("walk" .. body.lookingDir)
            end
    	else
    		vx, vy = 0, 0
            body:setSequence("idle" .. body.lookingDir)
    	end

        body:play()
        body:setLinearVelocity(vx, vy)
        body.lastDir = body.lookingDir
        return true
    end

    function body.attackRanged(self)
        print("attackRanged")
        return true
    end

    function body.block(self)
        print("block")
    end

    function body.hold(self)
        self:setLinearVelocity(0, 0)
    end

    function body.takeDamage(self, fromAngle, damage)
        self.hp = self.hp - damage
        if self.hp <= 0 then
            self.isAlive = false
        end

        if self.isAlive then
            local force = 0.3
            -- Add little variance to pushback direction. Second random chooses between two values
            local pushVar = math.random() * math.random() < 0.5 and -0.25 or 0.25
            local pushAngle = fromAngle + pushVar
            self:applyLinearImpulse( cos(pushAngle)*force, sin(pushAngle)*force, self.x, self.y )
            self.alpha = 0.5

            timer.after(300, function()
                self.alpha = 1
                self:hold()
            end )
        else
            self.alpha = 0
            print( self.id .. " has died" )
        end
    end

    -- Tee tästä hitboxParams jossa angle, anchorX ja Y sekä rotation
    local attackAngles = {
        left = 180,
        right = 360,
        down = 90,
        up = 270,
    }

    function body.attackMelee(self, direction)
        -- prevent overlapping attacks
        if not self.isAttacking then
            local hitTimer
            self.isAttacking = true
            self.lookingDir = direction
            self:setSequence("attack" .. direction)
            self:play()

            local targetAngle = math.rad(attackAngles[direction])
            local hitX = self.x + cos(targetAngle) * self.meleeRange
            local hitY = self.y + sin(targetAngle) * self.meleeRange

            timer.after(400, function()
                -- local l = display.newLine( self.x, self.y, hitX, hitY )
                local hits = physics.rayCast( self.x, self.y, hitX, hitY, "unsorted" )

                if hits then
                    local firstObj = hits[1].object
                    if firstObj ~= self then
                        hits[1].object:takeDamage( targetAngle, self.attackPower or 50 )
                    end
                end
            end)

        end
    end


    if isEnemy then
        for k, v in pairs(defaultData.ai) do
            body[k] = v
        end

        function body.handleMovement(self, status )
            local distance = self:getDistance(player) --Distance to player
            local toX, toY = getAngle({ targetSelf = self, targetOther = player })    --Direction to player

            if status == "approach" then
                if distance < self.attackDistance then self:hold() return false end --close enought, no need to move
                self:setLinearVelocity(toX * self.speed, toY * self.speed)

                return true

            elseif status == "retreat" then
                if distance > self.safeDistance then self:hold() return false end -- already safe

                -- add slight random variance to avoid perfectly straight line
                local variance = 2  -- tweak this number for more/less randomness
                local randAngle = math.random() * variance - (variance / 2)  -- random between -variance/2 and +variance/2
                local cosVar = cos(randAngle)
                local sinVar = sin(randAngle)

                -- rotate vector slightly
                local finalX = -toX * cosVar - -toY * sinVar
                local finalY = -toX * sinVar + -toY * cosVar

                self:setLinearVelocity(finalX * self.speed, finalY * self.attack)
                return true
            end
        end
    end

    body:addEventListener("sprite", spriteListener)
    return body
end

-- Distance / angle helper funktions
function getDistance(from, to)
    local dx = from.x - to.x
    local dy = from.y - to.y
    return math.sqrt(dx*dx + dy*dy)
end

function getAngle(from, to, normalize)
    local angle = math.deg(math.atan2(to.y - from.y, to.x - from.x))
    if not normalize then
        return angle
    else
        angle = angle % 360
        if angle < 0 then angle = angle + 360 end
        return angle
    end
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        player = newCharacter(true,  display.contentCenterX, display.contentCenterY )
        enemy = newCharacter(false, player.x, player.y+100)

        local function update()
            -- enemy:handleAction()
        end

        function updateMouse(event)
            mouseX, mouseY = event.x, event.y
            -- if event.isPrimaryButtonDown then
                local angle = getAngle( player, { x = mouseX, y = mouseY }, true )

                if angle then
                    -- print( angle )
                    local attackDir

                    -- for i = 1, #mouseAngles do
                    --     local min, max, dir = mouseAngles[i].min, mouseAngles[i].max, mouseAngles[i].dir
                    --     if angle > min and angle < max then attackDir = dir break end
                    -- end
                    -- if attackDir then print( attackDir ) end
                    -- local attackDirection
                    -- if ( -135 >= angle or angle > 135 ) then
                    --     attackDirection = "left"
                    -- elseif ( -45 < angle and angle <= 45 ) then
                    --     attackDirection = "right"
                    -- elseif ( -135 < angle and angle <= -45 ) then
                    --     attackDirection = "up"
                    -- elseif ( 135 >= angle and angle > 45 ) then
                    --     attackDirection = "down"
                    -- end
                end

                -- if attackDirection then
                --     player:handleAnimation("attack", attackDirection)
                -- end
            -- end
        end

        controls.start(player, player.move)

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
                local r = random()
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