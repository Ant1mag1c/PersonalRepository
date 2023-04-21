local utils = require("Scripts.utils")
local map = require("Scripts.map")
local json = require( "json" )
local loadsave = require( "scripts.loadsave" )


local promt = {}


local function clickEvent(event)
	local mapData

	if event.target.id == "new" then
		mapData = map.generate({
			colWidth = 300,
			doublePathChance =  0.35,
			maxDoubleLevels = 2,
			pathCount = 3,
			stepHeight = 120,
			stepCount = 6,
			levelWidth = 40,
			levelHeight = 40,
			levelPad = 10,
			nodesPerForest = 6,
			stepsPerWater = 3,
			maxStores = 2,
			storeFirstSpawnStep = 3
		})

		mapSaveTable(mapData, "settings.json")

	else
		-- Lataa kartta tiedostosta
		mapData = mapLoadTable( "settings.json" )

	end

	map.render( mapData )

	display.remove( promt.group )
	promt.group = nil
	-- print(savedMap)

end

function openPromt()
	promt.group = display.newGroup()

	promt.layer1 = display.newRect( promt.group, display.contentCenterX, display.contentCenterY, display.contentWidth*0.5, display.contentWidth*0.4 )
	promt.layer1:setFillColor(0.7,0.7,0.7)



	for i = 1,2 do
		promt.button = display.newRect( promt.group, display.contentCenterX*0.65*i, display.contentCenterY, display.contentWidth*0.15, display.contentWidth*0.1 )
		promt.button:setFillColor(0,0.7,0)
		promt.button.id = i == 1 and "new" or "load"
		promt.button:addEventListener("touch", clickEvent)

		promt.name = i == 1 and "New map" or "Load old"

		promt.text = display.newText( promt.group, promt.name, promt.button.x, promt.button.y, native.systemFont, 30 ) or display.newText( promt.name, promt.button.x, promt.button.y, native.systemFont, 30 )
		-- print(promt.button.id)

	end
end

openPromt()

-- promt.button = display.newRect( display.contentCenterX*0.7, display.contentCenterY, display.contentWidth*0.15, display.contentWidth*0.1 )
-- promt.button1:setFillColor(0,0.7,0)
-- promt.button2 = display.newRect( display.contentCenterX*1.3, display.contentCenterY, display.contentWidth*0.15, display.contentWidth*0.1 )
-- promt.button2:setFillColor(0,0.7,0)


-- local mapData = map.generate({
-- 	colWidth = 300,
-- 	doublePathChance =  0.35,
-- 	maxDoubleLevels = 2,
-- 	pathCount = 3,
-- 	stepHeight = 120,
-- 	stepCount = 6,
-- 	levelWidth = 40,
-- 	levelHeight = 40,
-- 	levelPad = 10
-- })

-- map.render(mapData)



-- local saveMap = json.encode( mapData )
-- print( serializedJSON )

-- local loadMap = json.decode( serializedJSON )
-- table.print( newData )