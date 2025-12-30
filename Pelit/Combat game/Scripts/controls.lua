-- controls.lua
local controls = {}

local callbackMovement
local target
local hasStarted = false

-- Track keys currently held
local isPressed = {}

-- Track attack hold direction (“left”, “right”, “up”, “down”)
local heldAttackDir = nil

-- Movement keys (deterministic order)
local moveKeys = {
    w = true, s = true, a = true, d = true
}

-- Key bindings
local keyActions = {
    -- Movement
    w = { type = "move", vx = 0, vy = -1, dir = "up" },
    s = { type = "move", vx = 0, vy = 1,  dir = "down" },
    a = { type = "move", vx = -1,vy = 0, dir = "left" },
    d = { type = "move", vx = 1, vy = 0, dir = "right" },

    -- Attacks
    left  = { type = "attack", action = function(t) t:attackMelee("left") end },
    right = { type = "attack", action = function(t) t:attackMelee("right") end },
    up    = { type = "attack", action = function(t) t:attackMelee("up") end },
    down  = { type = "attack", action = function(t) t:attackMelee("down") end },

    space = { type = "attack", action = function(t) t:block() end },
}

---------------------------------------------------------------------

local function monitorControls()
    local vx, vy = 0, 0

    ---------------------------------------------------------
    -- MOVEMENT (only when not attacking)
    ---------------------------------------------------------
    if not target.isAttacking then
        if isPressed["w"] then vy = vy - 1 end
        if isPressed["s"] then vy = vy + 1 end
        if isPressed["a"] then vx = vx - 1 end
        if isPressed["d"] then vx = vx + 1 end

        -- Update facing direction
        if vy ~= 0 then
            target.lookingDir = vy < 0 and "up" or "down"
        elseif vx ~= 0 then
            target.lookingDir = vx < 0 and "left" or "right"
        end

        callbackMovement(vx, vy)
    else
        target:hold()
    end

    ---------------------------------------------------------
    -- AUTO-ATTACK (trigger again after animation ends)
    ---------------------------------------------------------
    if heldAttackDir and not target.isAttacking then
        local bind = keyActions[heldAttackDir]
        if bind then bind.action(target) end
    end
end

---------------------------------------------------------------------

local function onKeyEvent(event)
    local key = event.keyName
    local binding = keyActions[key]
    if not binding then return false end

    if event.phase == "down" then
        isPressed[key] = true

        if binding.type == "attack" then
            heldAttackDir = key

            if not target.isAttacking then
                binding.action(target)
            end
        end

    elseif event.phase == "up" then
        isPressed[key] = nil

        if binding.type == "attack" and heldAttackDir == key then
            heldAttackDir = nil
        end
    end

    return false
end

---------------------------------------------------------------------

function controls.start(player, movementCallback)
    if hasStarted then return end
    hasStarted = true

    target = player
    callbackMovement = movementCallback

    Runtime:addEventListener("enterFrame", monitorControls)
    Runtime:addEventListener("key", onKeyEvent)
end

function controls.stop()
    if not hasStarted then return end
    hasStarted = false

    isPressed = {}
    heldAttackDir = nil

    Runtime:removeEventListener("enterFrame", monitorControls)
    Runtime:removeEventListener("key", onKeyEvent)
end

function controls.isHoldingAttack()
    return heldAttackDir
end

return controls
