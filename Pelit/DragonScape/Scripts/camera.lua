local gamedata = require( "Scripts.gamedata" )
local camera = {}

local hasStarted = false
local cameraTarget
local cameraGroups

local halfWidth = display.actualContentWidth * 0.5
local halfHeight = display.actualContentHeight * 0.5

-- Kamera päivittyy joka frame. Se pyrkii pitämään kameran keskellä kohdetta, joka on määritelty camera.start funktiossa.
-- Todennäköisesti tämä kohde on pelaajahahmo. Kameralle ei ole asetettu mitään ulkorajoja.
local function update()
	local toX = cameraTarget.x - halfWidth
	local toY = cameraTarget.y - halfHeight - 150

	local cameraLimitL = gamedata.mapBounds.left or 20
	local cameraLimitR = gamedata.mapBounds.right or 409

	if toX <= cameraLimitL then
		toX = cameraLimitL
	end

	local rightOffset = halfWidth * 2
	if toX >= (cameraLimitR - rightOffset) then
		toX = cameraLimitR - rightOffset
	end

	-- Siirretään jokaista annettua display grouppia annetulla skaalalla. Tämän avulla voidaan luoda esim. parallax efekti.
	for i = 1, #cameraGroups do
		local group = cameraGroups[i][1]
		local scale = cameraGroups[i][2]

		group.x = -toX * scale
		group.y = -toY * scale
	end
end

-- Käynnistetään kamera ja kerrotaan sille mitä ryhmiä sen tulee liikuttaa, millä skaalalla ja mitä kohdetta se seuraa.
function camera.start( target, groups )
	-- Varmista ettei kameraa ole jo käynnistetty.
	if not hasStarted then
		hasStarted = true

		cameraTarget = target

		cameraGroups = {}
		for i = 1, #groups do
			cameraGroups[i] = { groups[i][1], groups[i][2] }
		end

		Runtime:addEventListener( "enterFrame", update )
	end
end

function camera.stop()
	if hasStarted then
		hasStarted = false

		Runtime:removeEventListener( "enterFrame", update )
	end
end


return camera