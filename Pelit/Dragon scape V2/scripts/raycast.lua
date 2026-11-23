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
		local offset = 4
		local attackRange = 60
		local wallRange = 5

		fromX = fromX + (offset * lookDir)

		if rayType == "platform" then
			targetID = "platform"
			secondID = "rope"
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

	local hits = physics.rayCast( fromX, fromY, toX, toY, "unsorted" )

	local hitID = nil

	if hits then
		for i = 1, #hits do
			local id = hits[i].object.id

			if id == targetID or id == secondID then

				hitID = id == targetID and targetID or secondID
				break

			end
		end
	end

	-- print(hitId)

	-- Debug line
	if line then
		local color = hitID and { 0, 1, 0 } or { 1, 0, 0 }

		line = display.newLine( from.parent, fromX, fromY, toX, toY )
		line:setStrokeColor( unpack(color) )

		timer.performWithDelay( 2, function () display.remove(line); line = nil end )
	end

	-- Return hitted object and also if it was required target
	return hitID or false, hits and hits[1].object
end



return m