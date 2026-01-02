local controls = {}

local callbackMovement
local callbackKey
local player

local hasStarted = false
local isPressed = {}

local loadsave = require("scripts.loadsave")

local keyMap = {}
for action, keys in pairs(loadsave.userdata.controls) do
	for i = 1, #keys do
		keyMap[keys[i]] = action
	end
end

----------------------------------------------------------------------------------

local function monitorMovement()
	if not player then return end

	local vx, vy = 0, 0

	if isPressed["left"]  then vx = vx - 1 end
	if isPressed["right"] then vx = vx + 1 end
	if isPressed["up"]    then vy = vy - 1 end
	if isPressed["down"]  then vy = vy + 1 end

	if isPressed["attackLeft"] then
		player:attack(-1)
	elseif isPressed["attackRight"] then
		player:attack(1)
	end

	callbackMovement(vx, vy)
end

----------------------------------------------------------------------------------

local function onKeyEvent(event)
	local action = keyMap[event.keyName]
	if not action then return end

	isPressed[action] = (event.phase == "down")
	callbackKey(action, event.phase)

	return true
end

----------------------------------------------------------------------------------

function controls.start(listenerMovement, listenerKey, target)
	if hasStarted then return end
	hasStarted = true

	callbackMovement = listenerMovement
	callbackKey = listenerKey
	player = target

	Runtime:addEventListener("enterFrame", monitorMovement)
	Runtime:addEventListener("key", onKeyEvent)
end

function controls.stop()
	if not hasStarted then return end
	hasStarted = false

	Runtime:removeEventListener("enterFrame", monitorMovement)
	Runtime:removeEventListener("key", onKeyEvent)

	for k in pairs(isPressed) do
		isPressed[k] = false
	end
end

return controls
