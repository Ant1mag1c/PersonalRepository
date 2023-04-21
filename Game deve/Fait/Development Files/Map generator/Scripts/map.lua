
local json = require( "json" )
local map = {}


--TODO: Kenttien sisällön määrittäminen - onko kenttä metsää, peltoa vai vettä, tai mikä event kentässä on (vihollinen, random event, kauppa, jne.)
--TODO: Kartan muistamisen korjaanminen, nyt kartta ei generoidu uudestaan kuin vain ctrl + r yhdistelmällä.
-- TODO: Kamera moduuli



-- groupDebug sisältää devauksessa hyödyllisiä debuggaus elementtejä.
local groupDebug = display.newGroup()
local groupMap = display.newGroup()
groupMap:insert( groupDebug )



local currentRow = 0
local prevNode
local startNode


local function movePlayer(event)
	local target = event.target
	local phase = event.phase

	if phase == "ended" then
		-- print( "currentRow:", currentRow, "target.row:", target.row )

		if target.row == currentRow + 1 then
			local isConnected = false
			for i = 1, #target.connected do
				if target.connected[i] == prevNode then
					isConnected = true
					break
				end
			end
			-- print( isConnected and "target is connected" or "target is not connected" )

			if isConnected then
				prevNode:setFillColor(1)
				currentRow = target.row
				prevNode = target
				target:setFillColor(0,1,0)
			end
		end
	end
end



local function drawRoute(from, to)
	if not from.route then
		from.route = {}
	end

	-- Pelin tulee tietää, että mitkä kentät ovat yhdistetty toisiinsa navigointia varten.
	if not from.connected then
		from.connected = {}
	end
	if not to.connected then
		to.connected = {}
	end

	from.route[#from.route+1] = display.newLine( groupMap, to.x, to.y, from.x, from.y )
	from.route[#from.route]:setStrokeColor( 1 )
	from.route[#from.route].strokeWidth = 4
	from.route[#from.route]:toBack()


	from.connected[#from.connected+1] = to
	to.connected[#to.connected+1] = from
end


-- Tarkista löytyykö haettu elementti annetusta taulukosta.
local function isDuplicateEntry( t, entry )
    local duplicate = false
    for i = 1, #t.connected do
        if t.connected[i] == entry then
            duplicate = true
            break
        end
    end
	return duplicate
end

-- Kirjataan jokaisesta kentästä tieto, että mihin muihin kenttiin se on yhdistetty reitillä.
local function addRouteData(from, to)
	if not from.connected then
		from.connected = {}
	end
	if not to.connected then
		to.connected = {}
	end

	if not isDuplicateEntry( from, to ) then
        from.connected[#from.connected+1] = to
	end
	if not isDuplicateEntry( to, from ) then
        to.connected[#to.connected+1] = from
	end

end


-- Generoidaan kentän layout, esim. montako kenttää, missä kentät ovat kartalla, mistä voi liikkua mihinkäkin, mitä kentissä on, jne.
-- Layout tallennetaan node taulukkoon, joka voidaan tallentaa tiedostoon, josta kenttä voidaan myöhemmin luoda samanlaisena uudestaan.
function map.generate(mapParams)

    mapParams = mapParams or {}
    -- Kartta generoinnin parametreja:
    local colWidth = mapParams.colWidth or 300
    local doublePathChance = mapParams.doublePathChance or  0.35
    local maxDoubleLevels =  mapParams.maxDoubleLevels or 2
    local pathCount = mapParams.pathCount or 3
    local stepHeight = mapParams.stepHeight or 120
    local stepCount = mapParams.stepCount or 6
    local levelWidth = mapParams.levelWidth or 40
    local levelHeight = mapParams.levelHeight or 40
    local levelPad = mapParams.levelPad or 10
    local nodesPerForest = mapParams.nodesPerForest or 3
    local stepsPerWater = mapParams.stepsPerWater or 3
    local maxStores = mapParams.maxStores or 1
    local storeFirstSpawnStep = mapParams.storeFirstSpawnStep or 3

    if storeFirstSpawnStep > stepCount then
        storeFirstSpawnStep = stepCount
    end


    --Automaattisesti lasketut map muuttujat
    local mapWidth = colWidth*pathCount
    local colWidthHalf = colWidth * 0.5
    local levelVarX = (colWidthHalf - levelWidth - levelPad*2)*0.5
    local levelMaxY = stepHeight - levelHeight*0.5 - levelPad
    local levelCount = 0

	-- Tallennetaan kartan luomiseen vaadittavat tiedot.
	local mapData = {}
	mapData.stepCount = stepCount
	mapData.mapWidth = mapWidth
	mapData.startNode = { x=mapWidth/2, y=stepHeight, type = "start", loc = {0,0,0} }
	mapData.bossNode =  { x=mapWidth/2, y=-(stepCount+1)*stepHeight, type = "end", loc = {stepCount+1, stepCount+1, stepCount+1} }

	local node = {}

    -- Generoidaan levelien sijainnit sekä asetetaan rajat levelien luonnille
    -- jonka jälkeen luodaan tieto kenttien toisiinsa yhdistymisistä
    for currentPath = 1, pathCount do
        node[currentPath] = {}

        local x = (currentPath-1)*colWidth
        local doubleLevels = 0

        for currentStep = 1, stepCount do
            node[currentPath][currentStep] = {}

            local y = -(currentStep-1)*stepHeight - math.random(levelHeight*0.5 + levelPad, levelMaxY)
            local levelsInStep = math.random() < doublePathChance and 1 or 2

            if levelsInStep == 1 then
                doubleLevels = 0
            else
                doubleLevels = doubleLevels + 1

                if doubleLevels > maxDoubleLevels then
                    levelsInStep = 1
                    doubleLevels = 0
                end
            end

            local connCount = node[currentPath][currentStep-1] and #node[currentPath][currentStep-1] or 1
            local buildConnection

            if levelsInStep == 2 and connCount == 2 then
                buildConnection = {}
                for n = 1, 2 do
                    buildConnection[n] = {}
                    buildConnection[n][n] = true
                end

                local r = math.random()

                if r < 0.35 then
                    buildConnection[1][2] = true

                elseif r < 0.7 then
                    buildConnection[2][1] = true

                end
            end

            for currentLevel = 1, levelsInStep do

                local levelX

                if levelsInStep == 1 then
                    levelX = x + colWidthHalf
                else
                    levelX = x + colWidthHalf / 2 + (currentLevel-1) * colWidthHalf
                end

                levelX = levelX + math.random(-levelVarX, levelVarX)

                local level = { x=levelX, y=y, type = "enemy", terrain = "field", loc = {currentPath,currentStep,currentLevel} }
                levelCount = levelCount + 1

                for l = 1, connCount do
                    local prev = node[currentPath][currentStep-1] and node[currentPath][currentStep-1][l] or mapData.startNode
                    local continue = not (buildConnection and not buildConnection[currentLevel][l])

                    if continue then
                        addRouteData(level, prev)
                    end
                end

                node[currentPath][currentStep][currentLevel] = level
            end
        end
    end






    -- Jokaiselle levelille luodaan oma conn taulukko johon lisätään ne levelit joihin
    -- kyseisestä levelistä yhdistytään.
    for currentPath = 1, pathCount do
        for currentStep = 1, #node[currentPath][stepCount] do
            local prev = node[currentPath][stepCount][currentStep]

            addRouteData(mapData.bossNode, prev)
        end
    end

    if stepCount > 2 then
        for currentStep = 1, pathCount-1 do
            local r = math.random()
            local doublePossible = stepCount > 5

            local rowA, rowB
            -- Luodaan yksi tai kaksi yhteyttä reittien väliin
            if not doublePossible or r < 0.05 then
                rowA = math.random(2, stepCount-1)

            else
                local middle = math.floor(stepCount*0.5)
                rowA = math.random(2, middle)
                rowB = math.random(middle+2, stepCount-1)

            end

            local rowOffsetA = math.random() < 0.5 and -1 or 1
            local fromA = node[currentStep][rowA][#node[currentStep][rowA]]
            local toA = node[currentStep+1][rowA+rowOffsetA][1]

            addRouteData(fromA, toA)

            if rowB then
                local rowOffsetB = math.random() < 0.5 and -1 or 1
                local fromB = node[currentStep][rowB][#node[currentStep][rowB]]
                local toB = node[currentStep+1][rowB+rowOffsetB][1]

                addRouteData(fromB, toB)
            end
        end
    end

    for currentPath = 1, pathCount do
        for currentStep = 1, stepCount do
            for currentLevel = 1, #node[currentPath][currentStep] do
                local connected = node[currentPath][currentStep][currentLevel].connected

                node[currentPath][currentStep][currentLevel].conn = {}
                for l = 1, #connected do
                    node[currentPath][currentStep][currentLevel].conn[l] = { connected[l].loc[1], connected[l].loc[2], connected[l].loc[3] }
                end
            end
        end
    end


    for currentPath = 1, pathCount do

        local stepNumber = math.random(stepCount)
        local levelNumber = math.random(#node[currentPath][stepNumber])

        local level = node[currentPath][stepNumber][levelNumber]
        level.terrain = "forest"

        local prev = level

        for _ = 1, nodesPerForest-1 do
            local _conn = prev.conn[math.random(#prev.conn)]
            local _currentPath = _conn[1]
            local _currentStep = _conn[2]
            local _currentLevel = _conn[3]


            -- if _currentStep == 0 then
            --     prev = mapData.startNode
            -- elseif _currentStep == stepCount+1 then
            --     prev = mapData.bossNode
            -- else
            --     prev = node[_currentPath][_currentStep][_currentLevel]
            -- end

            if _currentStep > 0 and _currentStep <= stepCount then
               prev = node[_currentPath][_currentStep][_currentLevel]

               if prev.terrain == "forest" then
                    prev.terrain = "deepForest"
                else
                    prev.terrain = "forest"
                end

            end


        end

    end

    -- Luodaan vesi alueita
    for currentPath = 1, pathCount do
        local waterCount = math.floor(stepCount / stepsPerWater)
        for _ = 1, waterCount do



            local stepNumber = math.random(stepCount)
            local levelNumber = math.random(#node[currentPath][stepNumber])

            local level = node[currentPath][stepNumber][levelNumber]

            if level.terrain == "forest" then
                level.terrain = "swamp"
            elseif level.terrain == "deepForest" then
                level.terrain = "morass"
            else
                level.terrain = "pond"

            end
        end
    end

    -- Varmistetaan että startNode ei ole metsä tai järvi, jne
    mapData.startNode.terrain = "start"

    -- TODO: Tarvitseeko bossNodelle luoda sama suoja kuin startNodelle?

    -- mapData.bossNode.terrain = "boss"


    -- TODO: Lisää loput level.typet ( sauna, randomEvent, enemyElite, aarre/luola, )
    -- jos level.type == enemy silloin generoidaan levelille uusi sisältö
    -- jos level.type esim store silloin sen päälle ei laiteta mitään
    local placement = {}
    placement.store = {}

    for i = 1, maxStores do

        local currentPath = math.random(pathCount)

        if not placement.store[currentPath] then
            placement.store[currentPath] = true

            local stepNumber = math.random(storeFirstSpawnStep ,stepCount)
            local levelNumber = math.random(#node[currentPath][stepNumber])

            local level = node[currentPath][stepNumber][levelNumber]
            level.type = "store"
        end
    end


	-- Poistetaan taulukoista tarpeeton data ennen kuin taulukko palautetaan funktiosta.
	-- Tämä tekee datasta helppolukuisempaa ja vähentää tallennettujen tiedostojen kokoa.
	for currentPath = 1, pathCount do
        for currentStep = 1, stepCount do
            for currentLevel = 1, #node[currentPath][currentStep] do
                node[currentPath][currentStep][currentLevel].loc = nil
                node[currentPath][currentStep][currentLevel].connected = nil
            end
        end
    end
    mapData.startNode.connected = nil
    mapData.startNode.loc = nil
    mapData.bossNode.connected = nil
    mapData.bossNode.loc = nil

	mapData.node = node
    return mapData
end


-- Piirretään kartta annetuiden tietojen mukaan.
function map.render( mapData )

    if type(mapData) ~= "table" then
        print( "WARNING: render() expected table, got ".. type(mapData) )
        return
    end

    -- Keskitetään kartta ruudulle.
    local mapOffsetX = ( display.actualContentWidth - mapData.mapWidth ) / 2
    groupMap.x = display.screenOriginX + mapOffsetX
    groupMap.y = 400

    -- Start node on aina kartan pohjalla.
    startNode = display.newCircle( groupMap, mapData.startNode.x, mapData.startNode.y, 20 )
    startNode.type = mapData.startNode.type
    startNode:setFillColor(0,1,0)
    startNode:addEventListener("touch", movePlayer)
    startNode.row = 0
    prevNode = startNode


    local bossNode = display.newCircle( groupMap, mapData.bossNode.x, mapData.bossNode.y, 20 )
    bossNode.type = mapData.bossNode.type
    bossNode:setFillColor(1)
    bossNode:addEventListener("touch", movePlayer)
    bossNode.row = mapData.stepCount + 1

	-- Asetetaan kaikki kentät tuttuun node taulukkoon, jolloin ne löytyvät
	-- samoilla tavoin map.generate() ja map.render() funktioiden taulukoissa.
	local node = {}
    for currentPath = 1, #mapData.node do
		node[currentPath] = {}
        for currentStep = 1, #mapData.node[currentPath] do
			node[currentPath][currentStep] = {}
            for currentLevel = 1, #mapData.node[currentPath][currentStep] do
                local data = mapData.node[currentPath][currentStep][currentLevel]
                local level = display.newCircle( groupMap, data.x, data.y, 20 )
                level.type = data.type
                level.terrain = data.terrain
                level:addEventListener("touch", movePlayer)
                level.row = currentStep

                -- Annetaan metsä leveleille vihreä sävy. Syvä metsä laatoille sävy on tummempi
                if level.terrain == "forest" then
                    level:setFillColor(0,1,0)
                elseif level.terrain == "deepForest" then
                    level:setFillColor(31/255, 105/255, 35/255)
                elseif level.terrain == "swamp" then
                    level:setFillColor(0,0,1)
                elseif level.terrain == "morass" then
                    level:setFillColor(0,0,0.7)
                elseif level.terrain == "pond" then
                    level:setFillColor(0.35,0.8,0.9)

                end


                level.overlay = display.newText( {
                    parent = groupMap,
                    x = level.x,
                    y = level.y,
                    text = level.type,
                    fontSize = 32,
                    font = native.systemFont,
                    align = "center",
                } )
                level.overlay:setFillColor(1,0,0)


				node[currentPath][currentStep][currentLevel] = level


            end
        end
    end

	-- Kun kentät on luotu, niin niihin pystytään viittaamaan mapData:ssa jokaisen
	-- noden kohdalla löytyvien "conn" taulukkojen sijantidatan avulla, jota voidaan
	-- käyttää reittien piirtämiseen kenttien välille.
    for currentPath = 1, #mapData.node do
        for currentStep = 1, #mapData.node[currentPath] do
            for currentLevel = 1, #mapData.node[currentPath][currentStep] do
                local data = mapData.node[currentPath][currentStep][currentLevel]
                local fromNode = node[currentPath][currentStep][currentLevel]
                local toNode

                for l = 1, #data.conn do
                    if data.conn[l][1] == 0 then
                        toNode = startNode
                    elseif data.conn[l][2] == mapData.stepCount+1 then
                        toNode = bossNode
                    else


                        local toRow = data.conn[l][1]
                        local toCol = data.conn[l][2]
                        local toStep = data.conn[l][3]

                        toNode = node[toRow][toCol][toStep]
                    end

                    drawRoute( fromNode, toNode )

                end
			end
		end
	end
end


function map.update()
	-- TODO: karttaan voisi tehdä päivitys funktion:
	-- Kun kartta on generoitu ja/tai renderöity, niin sen jälkeen meidän tulee kuitenkin vielä päivittää pelaajan sijainti
	-- kartalle, asettaa kameralle rajat, että paljonko sitä saa liikuttaa ja mihin suuntiin, sekä mistä kamera aloittaa jos
	-- pelaaja on liikkunut jo, mikä on prevNode (eli pelaajan aloitus node, jos pelaaja on liikkunut), jne. jne.
end



groupDebug.isVisible = false

local function moveMap(event)
    local target = event.target

    if event.phase == "began" then
        target.xStart = groupMap.x
        target.yStart = groupMap.y

        target.xEventStart = event.x
        target.yEventStart = event.y

    elseif event.phase == "moved" then
        groupMap.x = target.xStart + (event.x - target.xEventStart)
        groupMap.y = target.yStart + (event.y - target.yEventStart)

    end
end


local touchRect = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
touchRect:addEventListener("touch", moveMap )

touchRect.isHitTestable = true
touchRect.isVisible = false



return map