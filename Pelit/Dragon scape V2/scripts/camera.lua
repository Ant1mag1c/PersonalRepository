-- camera.lua
local camera = {}

-- internal state
local hasStarted = false
local cameraTarget
local cameraGroups = {}

-- camera position
local camX, camY
local targetX, targetY

-- settings
local cameraScale = 3        -- zoom level (2,3,4...)
local moveSpeed = 0.15       -- smoothing (0 = snap, 1 = instant)
local isManual = false

-- screen center
local halfWidth  = display.actualContentWidth  * 0.5
local halfHeight = display.actualContentHeight * 0.5

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

	-- move groups
	for i = 1, #cameraGroups do
		local group = cameraGroups[i].group
		local parallax = cameraGroups[i].parallax

		group.x = -toX * parallax
		group.y = -toY * parallax
	end
end

-- groups = { { group, parallax }, { group, parallax } }
function camera.start(target, groups)
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
