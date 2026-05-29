local animationTime = 800
local VerticalTime = animationTime / 2

return { 
	hero = {
		{ name = "idle", start = 1, count = 1, time = VerticalTime, loopCount = 0 },
		{ name = "idleSouth", frames = { 1 }, time = animationTime, loopCount = 0 },
		{ name = "idleNorth", frames = { 7 }, time = animationTime, loopCount = 0 },
		{ name = "idleWest", frames = { 24 }, time = VerticalTime, loopCount = 0 },
		{ name = "idleEast", frames = { 18 }, time = VerticalTime, loopCount = 0 },
		{ name = "walkSouth", frames = { 1, 2, 3, 4, 5, 6 }, time = VerticalTime, loopCount = 0 },
		{ name = "walkNorth", frames = { 7, 8, 9, 10, 11, 12 }, time = VerticalTime, loopCount = 0 },
		{ name = "walkEast", frames = { 13, 14, 15, 16, 17, 18 }, time = animationTime, loopCount = 0 },
		{ name = "walkWest", frames = { 19, 20, 21, 22, 23, 24 }, time = animationTime, loopCount = 0 },
	},
	
	campfire = {
		sheet = graphics.newImageSheet( "maps/sprites/campfire.png", { width = 32, height = 32, numFrames = 4 } ), 

		{ name = "default", frames = { 4 }, time = animationTime/2, loopCount = 0 },
		{ name = "burning", frames = { 1, 2, 3 }, time = animationTime/2, loopCount = 0 },
	}
}
