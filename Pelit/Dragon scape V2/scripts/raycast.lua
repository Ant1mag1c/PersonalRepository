local m = {}


function m.newRay( from, rayType )
	if not from or not from.id or not rayType then
		return false
	end


	local fromX, fromY = from.x, from.y - 10
	local toX, toY
	local line = false

	-- Handle ray parameters according to rayType
	if from.id == "enemy" then
		local lookDir = from.lookDir
		local offset = 5

		fromX = fromX + (offset * lookDir)

		if rayType == "platform" then
			local lenght = 20
			-- line = true

			toX, toY = fromX, (fromY + lenght)


		elseif rayType == "attack" then
			local lenght = 20
			-- line = true

			toX, toY = fromX + (lenght * lookDir), fromY
			rayType = "player"

		elseif rayType == "wall" then
			local lenght = 5
			-- line = true

			toX, toY = fromX + (lenght * lookDir), fromY
		end

	elseif from.id == "player" then
	end

	local hits = physics.rayCast( fromX, fromY, toX, toY, "closest" )
	local hitId = hits and hits[1].object.id

	-- Debug line
	if line then
		local color = hits and hits[1] and hitId == rayType
			and { 0, 1, 0 }
			or { 1, 0, 0 }

		line = display.newLine( from.parent, fromX, fromY, toX, toY )
		line:setStrokeColor( unpack(color) )

		timer.performWithDelay( 2, function () display.remove(line); line = nil end )
	end

	-- Return true if hit matches rayType. Remember: only one value returned
	return hits and hitId == rayType or false
end



return m