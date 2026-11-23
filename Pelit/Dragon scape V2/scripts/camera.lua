-- camera.lua
local camera = {}

-- internal state
local hasStarted = false
local cameraTarget
local cameraGroups = {}
local levelBorder = {}

-- camera position
local camX, camY
local targetX, targetY

-- settings
local cameraScale = 1     -- zoom level (2,3,4...)
local moveSpeed = 0.02      -- smoothing (0 = snap, 1 = instant)
local isManual = false

-- screen center
local offsetX = 0.6
local offsetY = 0.8
local halfWidth  = display.actualContentWidth  * offsetX
local halfHeight = display.actualContentHeight * offsetY

------------------------------------------------
-- INTERNAL UPDATE
------------------------------------------------
local function update()
	-- choose target position
	if not isManual and cameraTarget then
		targetX = cameraTarget.x
		targetY = cameraTarget.y
	end

	-- initialize camera position
	if not camX then
		camX = targetX
		camY = targetY
	end

	-- smooth movement
	camX = camX + (targetX - camX) * moveSpeed
	camY = camY + (targetY - camY) * moveSpeed

	-- pixel-perfect rounding (VERY important)
	local px = math.floor(camX * cameraScale + 0.5)
	local py = math.floor(camY * cameraScale + 0.5)

	local toX = px - halfWidth
	local toY = py - halfHeight

	local cameraLimitR = levelBorder.width + 75
	local cameraLimitL = 0

	if toX <= cameraLimitL then
		toX = cameraLimitL
	end

	local rightOffset = halfWidth * 2
	if toX >= (cameraLimitR - rightOffset) then
		toX = cameraLimitR - rightOffset
	end

	-- move groups
	for i = 1, #cameraGroups do
		local group = cameraGroups[i].group
		local parallax = cameraGroups[i].parallax

		group.x = (-toX * parallax)
		group.y = -toY * parallax
	end
end

-- groups = { { group, parallax }, { group, parallax } }
function camera.start(target, groups, border)
	if hasStarted then return end
	hasStarted = true

	cameraTarget = target
	cameraGroups = {}

	for i = 1, #groups do
		local g = groups[i][1]
		local p = groups[i][2] or 1

		g.xScale = cameraScale
		g.yScale = cameraScale

		cameraGroups[i] = {
			group = g,
			parallax = p
		}
	end

	targetX = target.x
	targetY = target.y

	levelBorder = border

	Runtime:addEventListener("enterFrame", update)
end

-- stop camera
function camera.stop()
	if not hasStarted then return end
	hasStarted = false

	Runtime:removeEventListener("enterFrame", update)
end

-- smoothly move camera to position
function camera.moveTo(x, y, instant)
	isManual = true
	targetX = x
	targetY = y

	if instant then
		camX = x
		camY = y
	end
end

-- resume following target
function camera.followTarget()
	isManual = false
end

-- set zoom (integer only!)
function camera.setScale(scale)
	cameraScale = math.max(1, math.floor(scale))

	for i = 1, #cameraGroups do
		local g = cameraGroups[i].group
		g.xScale = cameraScale
		g.yScale = cameraScale
	end
end

-- set smoothing
function camera.setSmoothness(value)
	moveSpeed = math.min(1, math.max(0, value))
end

return camera
