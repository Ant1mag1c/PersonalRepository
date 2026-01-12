local m = {}

local settings = {
	platform = {
		index = 1,
		targetID = "platform",
		startX = 5,
		startY = 5,
		endX = 5,
		endY = 13,
		-- debugLine = true,
	},

	player = {
		index = 2,
		targetID = "player",
		startX = 0,
		startY = -8,
		endX = 40, --Attack range
		endY = -8,
		debugLine = true,
	},

	enemy = {
		startX = 0,
		startY = 0,
		endX = 0,
		endY = 0,
	},

}

local lines = {}

function m.newRay( character, direction, targetID  )
	local data = settings[targetID]

	if not data then return false end
	local x1 = character.x + data.startX
	local x2 = character.x + data.endX * direction or 1
	local y1 = character.y + data.startY
	local y2 = character.y + data.endY

	local hits = physics.rayCast( x1, y1, x2, y2, "closest" )


 	if data.debugLine then
		local index = data.index
		local rayColor = hits and { 1,0,0 } or { 0,1,0 }

		local thisLine = display.newLine( character._parent, x1, y1, x2, y2 )
		thisLine:setStrokeColor( unpack(rayColor) )
		thisLine.strokeWidth = 2

		lines[index] = thisLine

		timer.performWithDelay(5, function()
		    if thisLine and thisLine.removeSelf then
		        display.remove(thisLine)
		    end
		    if lines[index] == thisLine then
		        lines[index] = nil
		    end
		end )

	end


	-- Tarkistetaan löytyykö osumista targetID ja lopetetaan loop siihen
    if hits then
	    for i = 1, #hits do
	        local hitObject = hits[i].object
            local isStairs = hitObject.id == "platform" and hitObject.isStairs == true

	        if hitObject.id == targetID and not isStairs then
                return true
            end
	    end
	end

    return false
end

return m