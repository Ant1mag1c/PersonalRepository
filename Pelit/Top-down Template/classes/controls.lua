-- controls.lua
-- Keyboard input module. Reads key bindings from user settings and provides
-- normalized movement vectors and key action callbacks.
--
-- Usage:
--   local controls = require("classes.controls")
--   controls.start( onMovement, onKeyAction )
--   controls.stop()
--
-- onMovement( vx, vy ) is called every frame with normalized direction values.
-- onKeyAction( action, phase ) is called when a bound key is pressed or released.
-- Actions are: "left", "right", "up", "down", "interact", "menu".

local controls = {}

local callbackMovement = nil
local callbackKey = nil

local hasStarted = false
local isPressed = {}

local loadsave = require( "classes.loadsave" )

-- Build a reverse lookup table: key name -> action name.
-- The user settings store controls as { action = { key1, key2, ... } },
-- but at runtime we need to quickly look up which action a pressed key maps to.
local key = {}

local function rebuildKeyMap()
	-- Clear existing mappings (wipe in-place to preserve upvalue reference).
	for k in pairs( key ) do
		key[k] = nil
	end
	-- Rebuild from current userdata.
	for action, keyNames in pairs( loadsave.userdata.controls ) do
		for i = 1, 2 do
			if keyNames[i] then
				key[keyNames[i]] = action
			end
		end
	end
end

-- Build initial key map.
rebuildKeyMap()


local function monitorMovement()
	local vx, vy = 0, 0

	if isPressed["left"] then vx = vx - 1 end
	if isPressed["right"] then vx = vx + 1 end
	if isPressed["up"] then vy = vy - 1 end
	if isPressed["down"] then vy = vy + 1 end

	-- Normalize to prevent faster diagonal movement
	local mag = math.sqrt(vx * vx + vy * vy)
	if mag > 0 then
		vx = vx / mag
		vy = vy / mag
	end

	-- Epsilon check to avoid tiny float errors
	local epsilon = 1e-6
	if math.abs(vx) < epsilon then vx = 0 end
	if math.abs(vy) < epsilon then vy = 0 end

	callbackMovement(vx, vy)
end

local function monitorAttack()
    if not callbackKey then return end

    if isPressed["attackLeft"] then
        callbackKey("attackLeft", "held")
    elseif isPressed["attackRight"] then
        callbackKey("attackRight", "held")
    elseif isPressed["attackUp"] then
        callbackKey("attackUp", "held")
    elseif isPressed["attackDown"] then
        callbackKey("attackDown", "held")
    end
end

local function onKeyEvent( event )
	local action = key[event.keyName]
	-- print( event.phase, event.keyName, action )

	if action then
		isPressed[action] = (event.phase == "down")

		callbackKey( action, event.phase )
	end
end


-- Start listening for keyboard input. Call this when the scene becomes active.
-- listenerMovement( vx, vy ) is called every frame with normalized direction.
-- listenerKey( action, phase ) is called on key press/release for bound keys.
function controls.start( listenerMovement, listenerKey )
	if not hasStarted then
		hasStarted = true

		callbackMovement = listenerMovement
		callbackKey = listenerKey

		Runtime:addEventListener( "enterFrame", monitorAttack )
		Runtime:addEventListener( "enterFrame", monitorMovement )
		Runtime:addEventListener( "key", onKeyEvent )
	end
end


-- Stop listening for keyboard input and reset all key states.
function controls.stop()
	if hasStarted then
		hasStarted = false

		Runtime:removeEventListener( "enterFrame", monitorMovement )
		Runtime:removeEventListener( "enterFrame", monitorAttack )
		Runtime:removeEventListener( "key", onKeyEvent )

		for action, _ in pairs( isPressed ) do
			isPressed[action] = false
		end
	end
end

-- Rebuild the reverse lookup table from current userdata.
-- Call this after modifying loadsave.userdata.controls at runtime.
function controls.rebuildKeyMap()
	rebuildKeyMap()
end


-- Return the current control bindings table.
function controls.getBindings()
	return loadsave.userdata.controls
end


-- Return whether controls are currently listening for input.
function controls.isActive()
	return hasStarted
end

return controls