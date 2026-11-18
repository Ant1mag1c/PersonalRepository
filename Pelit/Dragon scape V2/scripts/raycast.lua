local m = {}


function m.newRay( from, rayType )
	if not from or not from.id or not rayType then
		return false
	end


	local fromX, fromY = from.x, from.y - 10
	local toX, toY
	local line = false
	local targetID = nil
	local secondID = nil


	-- Handle ray parameters according to rayType
	if from.id == "enemy" then
		local lookDir = from.lookDir
		local offset = 5
		local attackRange = 60
		local wallRange = 5

		fromX = fromX + (offset * lookDir)

		if rayType == "platform" then
			targetID = "platform"
			local lenght = 20
			-- line = true

			toX, toY = fromX, (fromY + lenght)


		elseif rayType == "attack" then
			targetID = "player"
			local lenght = attackRange
			line = true

			toX, toY = fromX + (lenght * lookDir), fromY

		elseif rayType == "wall" then
			targetID = "wall"
			secondID = "obstacle"
			local lenght = wallRange
			-- line = true

			toX, toY = fromX + (lenght * lookDir), fromY
		end

	elseif from.id == "player" then
	end

	local hits = physics.rayCast( fromX, fromY, toX, toY, "closest" )
	local hitId = hits and hits[1].object.id

	-- Debug line
	if line then
		local color = hits and hits[1] and ( hitId == targetID or hitId == secondID )
			and { 0, 1, 0 }
			or { 1, 0, 0 }

		line = display.newLine( from.parent, fromX, fromY, toX, toY )
		line:setStrokeColor( unpack(color) )

		timer.performWithDelay( 2, function () display.remove(line); line = nil end )
	end

	-- Return true if hit matches rayType. Remember: only one value returned
	return hits and hitId == targetID or hits and hitId == secondID or false
end



return m