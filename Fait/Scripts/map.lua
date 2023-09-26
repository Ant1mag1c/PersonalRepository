local composer = require("composer")
local screen = require("Scripts.screen")
local userdata = require("Scripts.userdata")
local playerStatusBar = require("Widgets.playerStatusBar")
local map = {}

-----------------------------------------------------------------------

local hasStarted = false
local currentState


local imageScale = 0.25
local levelCenterOffset = 40
local imageWidth = 300 * imageScale
local imageHeight = 600 * imageScale

local hitMask = graphics.newMask( "Resources/Images/Levels/levelMask.jpg" )

local groupMap
local player

local moveMapDistance
local mouseX = 0
local mouseY = 0
local prevHighlighted
local currentNeighbours
local nodeList
local pathList
local gameNode
local currentRow
local prevNode
local startNode
local mapWidth
local maxScale = 1.2
local defaultScale = 1

-----------------------------------------------------------------------

local function darkenLevel(target)
	local intensity = 0.5
	target:setFillColor( intensity )
	target.typeView:setFillColor( intensity )
	target.terrainView:setFillColor( intensity )
end


-- Liikutetaan pelaajaa kartalla
local function movePlayer(event)
	local target = event.target
	local phase = event.phase

	if phase == "ended" then
		-- print( "currentRow:", currentRow, "target.row:", target.row )
        if moveMapDistance < 5 then

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
                    currentRow = target.row
                    prevNode = target
                    currentNeighbours = prevNode.connected




                    -- Julkistetaan liikkumiselle olennaisisa muuttujia liikkumiselle ja annetaan
                    -- pelaajalle moveCost joka tulee maksaa ennen jokaista liikkumista kartalla
                    local playerHP = userdata.player.sisuCurrent
                    local moveCost = userdata.moveCost
                    local isBleeding = userdata.isBleeding
                    local bleedPenalty = userdata.bleedPenalty
                    local bleedCount = userdata.bleedCount



                    if not isBleeding then
                        userdata.player.sisuCurrent = userdata.takeDamage(playerHP, moveCost)
                    end

                    -- Ajetaan bleed ehto jos havaitaan pelaajan vuotavan
                    if bleedCount > 0 then
                        print("I'm BLEEDING for", bleedCount,  "turns")
                        isBleeding = true
                        bleedCount = bleedCount - 1
                        userdata.bleedCount = bleedCount

                        userdata.player.sisuCurrent = userdata.takeDamage(playerHP, bleedPenalty)

                    else
                        isBleeding = false

                    end



                    -- print(isBleeding, "count:", bleedCount, "/", userdata.bleedCount)

                    playerStatusBar.update()

                    --  Luodaan pelaajalle liikkumi animaatio

                    zoomOutParams = {time = 500, xScale = 0.75, yScale = 0.75+0.1, onComplete=function()  transition.to( player, zoomInParams )  end  }
                    zoomInParams = {time = 500, xScale = 0.75-0.1, yScale = 0.75-0.1, onComplete=function()  transition.to( player, zoomOutParams )   end }

                    transition.to( player, zoomInParams )

                    -- TODO: Pelaaja liikkuu samalla nopeudella jokaisen matkan joka tekee lyhyistä väleistä turhan pitkäkestoisia
                    -- Kehitä kaava ylläpitämään sama nopeus joka etäisyydellä
                    transition.to(player, {time=2000, x=prevNode.x, y=prevNode.y, onComplete=function() transition.cancel(player)


                        for i = 1, #nodeList do
                            if nodeList[i].row < currentRow then
                                darkenLevel( nodeList[i] )
                            end
                        end
                        for i = 1, #pathList do
                            if pathList[i].row <= currentRow then
                                pathList[i]:setStrokeColor( 0.5, 0.5 )
                            end
                        end

                        local levelType = target.type

                        local options = {
                            isModal = true,
                            effect = "fade",
                            time = 250,
                            params = {
                                terrain = target.terrain,
                                type = levelType,
                                path = target.path,
                                row = target.row,
                                level = target.level,
                            }
                        }

                        local overlayScene
                        if levelType == "store" then
                            overlayScene = "scenes.deck"
                            options.params.isStore = true

                        elseif levelType == "sauna" or levelType == "treasure" or levelType == "randomEvent" then
                            overlayScene = "scenes.event"

                        end

                        if overlayScene then
                            composer.showOverlay( overlayScene, options )
                        else
                            composer.gotoScene( "scenes.battle", options )
                        end

                    end
                })


					-- Tummenna taakse jääneet kentät ja polut, jotta pelaaja näkee mihin suuntaan hän voi liikkua.

                end
			end
		end
	end
	return true
end


local function setScale(target, scale)
    target.terrainView.xScale, target.terrainView.yScale = scale, scale
    target.typeView.xScale, target.typeView.yScale = scale, scale
    target.xScale, target.yScale = scale, scale
end


local function highlightLevel()
    local outOfBounds = true
    for i = 1, #nodeList do
        local distance = math.sqrt( ( (mouseX-groupMap.x) - nodeList[i].x )^2 + ( (mouseY-groupMap.y) - nodeList[i].y )^2 )

        if distance <= 36 then
            outOfBounds = false
            local isConnected = false

            for j = 1, #currentNeighbours do
				if currentNeighbours[j] == nodeList[i] and currentRow + 1 == nodeList[i].row then
					isConnected = true
					break
				end
			end

            if isConnected then
                if prevHighlighted then
                    if prevHighlighted ~= nodeList[i] then
                        setScale(prevHighlighted, defaultScale)
                        setScale(nodeList[i], maxScale)
                        prevHighlighted = nodeList[i]
                    end

                else
                    setScale(nodeList[i], maxScale)
                    prevHighlighted = nodeList[i]
                end

            else
                if prevHighlighted then
                    setScale(prevHighlighted, defaultScale)
                    prevHighlighted = nil
                end

            end
            break
        end
    end

    if outOfBounds then
        if prevHighlighted then
            setScale(prevHighlighted, defaultScale)
            prevHighlighted = nil
        end

    end
end

local function onMouseEvent(event)
    mouseX, mouseY = event.x, event.y - levelCenterOffset
end

-- Piiretään levelien väliset route viivat
local function drawRoute(from, to, step)
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

	from.route[#from.route+1] = display.newLine( groupMap, to.x, to.y + levelCenterOffset, from.x, from.y + levelCenterOffset )
	from.route[#from.route]:setStrokeColor( 0.2 )
	from.route[#from.route].strokeWidth = 4
	from.route[#from.route]:toBack()
	from.route[#from.route].row = step

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

--Annetaan jokaiselle nodetyypille raja-arvot
local function setNodeContents( nodeContents, levelType, maxCount, minCount, maxPerPath )

    if not nodeContents[levelType] then
        nodeContents[levelType] = {}
    end

    nodeContents[levelType].maxCount = nodeContents[levelType].maxCount or maxCount
    nodeContents[levelType].minCount = nodeContents[levelType].minCount or minCount
    nodeContents[levelType].maxPerPath = nodeContents[levelType].maxPerPath or maxPerPath
    nodeContents[levelType].count = 0
end


local function updateTerrainAnchor( target, terrainType )
	-- Jokaisen kuvan "teksturii" on erilainen, joten ankkuripisteet pitää määritellä erikseen.
	local anchorX, anchorY
	if terrainType == "field" then
		anchorX, anchorY = 0.467, 0.733
	elseif terrainType == "morass" then
		anchorX, anchorY = 0.557, 0.772
	elseif terrainType == "pond" then
		anchorX, anchorY = 0.5, 0.758
	elseif terrainType == "swamp" then
		anchorX, anchorY = 0.5, 0.783
	end

	-- Ankkuuripisteiden päivityksen jälkeen terrainView:n sijainti pitää päivittää myös.
	target.anchorX, target.anchorY = anchorX, anchorY

	-- Calculate new position based on new anchor
	local dx, dy = (anchorX - 0.5) * target.width, (anchorY - 0.5) * target.height
	target.x, target.y = target.x + dx, target.y + dy
end


-- Piiretään levelit ja laitetaan niihin animaatiot ja muu tarpeellinen data.
local function drawLevel( nodeData, path, row, level )
    local newNode = display.newImageRect( groupMap, "Resources/Images/Levels/level.png",  imageWidth, imageHeight )
    -- startNode = display.newImageRect( groupMap, "Resources/Images/Levels/level.png",  imageWidth, imageHeight )
    newNode.x, newNode.y = nodeData.x, nodeData.y
    newNode.type = nodeData.type
    newNode.terrain = nodeData.terrain
	newNode:addEventListener("touch", movePlayer)

	-- Lisätään kenttien pohjiin maskit, jotta painallukset grafiikoiden
	-- läpinäkyviin alueisiin ignorettaisiin.
	newNode:setMask( hitMask )
	newNode.maskScaleX, newNode.maskScaleY = imageScale, imageScale

	-- path, row ja level ovat tärkeitä, koska ne kertovat, mihin kenttään pelaaja voi siirtyä (tai siirtyi).
	newNode.path = path
    newNode.row = row
	newNode.level = level

    if nodeData.terrain then
        newNode.terrainView = display.newImageRect( groupMap, "Resources/Images/Levels/" .. nodeData.terrain .. ".png",  imageWidth, imageHeight )

        if newNode.terrainView then
            newNode.terrainView.x, newNode.terrainView.y = nodeData.x, nodeData.y
        end
    end


    newNode.typeView = display.newImageRect( groupMap, "Resources/Images/Levels/" .. nodeData.type .. ".png",  imageWidth, imageHeight )

    if newNode.typeView then
        newNode.typeView:scale(defaultScale, defaultScale)
        newNode.typeView.x, newNode.typeView.y = nodeData.x, nodeData.y
    end

	-- Siirretään uudet kentät aina taakse, jotta ne eivät peitä aiempia kenttiä,
	-- joiden puut, pellot, ym. saattavat mennä kentän kanssa päällekkäin.
	if newNode.typeView then
		newNode.typeView:toBack()
	end
	if newNode.terrainView then
		newNode.terrainView:toBack()
	end
	newNode:toBack()

    -- Lisätään "field terraineille animaatio"
    local duration = 2000 + math.random(-100, 100)

    if newNode.terrain == "field" or newNode.terrain == "morass" or newNode.terrain == "pond" or newNode.terrain == "swamp" then
		-- Rotaation kanssa pitää olla tarkkana ankkuripisteen kanssa, jotta animaatio toimii oikein.
		updateTerrainAnchor( newNode.terrainView, newNode.terrain )

        local random = math.random( 5, 10 )
		local rotateLeft, rotateRight

        function rotateRight()
            transition.to(newNode.terrainView, {rotation=random, time=duration, tag="map", onComplete=rotateLeft} )
        end

        function rotateLeft()
            transition.to(newNode.terrainView, {rotation=-random, time=duration, tag="map", onComplete=rotateRight} )
        end

        newNode.terrainView.rotation = -random
        rotateRight()

    else

		local resetLevel, pulseLevel

		function pulseLevel()
            local random = math.random(3, 7)
			transition.to(newNode.terrainView.path, { x1=-random, x4=random, time=duration, tag="map", onComplete=resetLevel} )
		end

		function resetLevel()
			transition.to(newNode.terrainView.path, { x1=-0, x4=0, time=duration, tag="map", onComplete=pulseLevel} )
		end

        pulseLevel()

    end

    return newNode
end


local function initTouch( event )
    local target = event.target

    target.xStart = groupMap.x
    target.yStart = groupMap.y
    target.xEventStart = event.x
    target.yEventStart = event.y
end


-- Siirretään karttaa hiiren avulla.
local xStartMap, yStartMap
local function moveMap(event)
    local target = event.target

    if event.phase == "began" then
        initTouch( event )
        moveMapDistance = 0
		xStartMap, yStartMap = event.x, event.y

    elseif event.phase == "moved" then
		if not xStartMap then
			initTouch( event )
			moveMapDistance = 0
			xStartMap, yStartMap = event.x, event.y
		end

		local deltaX = event.x - target.xEventStart
        local deltaY = event.y - target.yEventStart

        moveMapDistance = math.sqrt( (event.x - xStartMap)^2 + (event.y - yStartMap)^2 )
		-- print( "moveMapDistance: " .. moveMapDistance )

        groupMap.x = target.xStart + deltaX
        groupMap.y = target.yStart + deltaY

        if groupMap.x <= groupMap.dragMinX  then
            groupMap.x = groupMap.dragMinX
            initTouch( event )

        elseif groupMap.x >= groupMap.dragMaxX then
            groupMap.x = groupMap.dragMaxX
            initTouch( event )
        end

        if groupMap.y <= groupMap.dragMinY then
            groupMap.y = groupMap.dragMinY
            initTouch( event )

        elseif groupMap.y >= groupMap.dragMaxY then
            groupMap.y = groupMap.dragMaxY
            initTouch( event )
        end

	else
		xStartMap, yStartMap = nil, nil

	end
end


-----------------------------------------------------------------------

-- Generoidaan kentän layout, esim. montako kenttää, missä kentät ovat kartalla, mistä voi liikkua mihinkäkin, mitä kentissä on, jne.
-- Layout tallennetaan node taulukkoon, joka voidaan tallentaa tiedostoon, josta kenttä voidaan myöhemmin luoda samanlaisena uudestaan.
function map.generate(mapParams, isLastMap)

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

    local nodeContents = mapParams.nodeContents or {}
    setNodeContents( nodeContents, "elite", 1, 1, 1 )
    setNodeContents( nodeContents, "sauna", 1, 1, 1)
    setNodeContents( nodeContents, "treasure", 1, 1, 1 )
    setNodeContents( nodeContents, "store", 1, 1, 1 )
    setNodeContents( nodeContents, "randomEvent", 1, 2, 1 )


    --Automaattisesti lasketut map muuttujat
    local _mapWidth = colWidth*pathCount
    local colWidthHalf = colWidth * 0.5
    local levelVarX = (colWidthHalf - levelWidth - levelPad*2)*0.5
    local levelMaxY = stepHeight - levelHeight*0.5 - levelPad
    local levelCount = 0

	-- Tallennetaan kartan luomiseen vaadittavat tiedot.
	local mapData = {}
	mapData.stepCount = stepCount
	mapData.mapWidth = _mapWidth
	mapData.startNode = { x=_mapWidth/2, y=stepHeight, type = "startNode", loc = {0,0,0} }
	mapData.bossNode =  { x=_mapWidth/2, y=-(stepCount+1)*stepHeight, type = "bossNode", loc = {stepCount+1, stepCount+1, stepCount+1} }

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
            local levelsInStep = math.random() <= doublePathChance and 2 or 1

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

    -- Luodaan kartalle metsä laatat
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



    mapData.startNode.terrain = math.random() < 0.5 and "forest" or "field"

    if isLastMap then
        mapData.bossNode.terrain = "kipu"
    else
        mapData.bossNode.terrain = "mountain"
    end



    local placement = {}

    for k, _ in pairs(nodeContents) do
        placement[k] = {}
        for i = 1, pathCount do
            placement[k][i] = 0
        end
    end


    local function assingNodeType( levelType )
        local data = nodeContents[levelType]
        local maxIter = 1000
        local currentIter = 0


        if data.maxCount <= 0 then
            return
        end


        local firstStep = math.max( data.firstStep or 1, 1)
        local lastStep = math.max( data.lastStep or stepCount, firstStep )

        if lastStep > stepCount then
            lastStep = stepCount
        end


        repeat
            local stop = false
            currentIter = currentIter + 1

            local currentPath = math.random(pathCount)

            if placement[levelType][currentPath] < data.maxPerPath then


                local stepNumber = math.random(firstStep ,lastStep)
                local levelNumber = math.random(#node[currentPath][stepNumber])

                local level = node[currentPath][stepNumber][levelNumber]

                if level.type == "enemy" then
                    local canPlace = true
                    local _conn = level.conn
                    for i = 1, #_conn do
                        local _currentPath = _conn[i][1]
                        local _currentStep = _conn[i][2]
                        local _currentLevel = _conn[i][3]

                        if _currentStep > 0 and _currentStep < stepCount + 1 then
                            local connectedNode = node[_currentPath][_currentStep][_currentLevel]

                            if connectedNode.type == levelType then
                                canPlace = false

                                break
                            end

                        end

                    end

                    if canPlace then
                        placement[levelType][currentPath] = placement[levelType][currentPath] + 1
                        level.type = levelType
                        data.count = data.count + 1
                        stop = data.count >= data.minCount and math.random() < 0.3
                    end
                end
           end

        until currentIter == maxIter or data.count == data.maxCount or stop
    end

    assingNodeType("store")
    assingNodeType("elite")
    assingNodeType("sauna")
    assingNodeType("treasure")
    assingNodeType("randomEvent")


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
function map.render( parent, mapData )

    if type(mapData) ~= "table" then
        print( "WARNING: render() expected table, got ".. type(mapData) )
        return
    end

	-- Kerätään tietoja kartasta, jotta niitä voidaan käyttää myöhemmin.
	mapWidth = mapData.mapWidth

    groupMap = display.newGroup()
    parent:insert(groupMap)

    startNode = drawLevel( mapData.startNode, 0, 0, 0 )

    local bossNode = drawLevel( mapData.bossNode, mapData.stepCount + 1, mapData.stepCount + 1, mapData.stepCount + 1 )

	-- Lisätään kentät gameNode taulukkoon, jolloin ne ovat löydettävissä
	-- funktion ulkopuolella ja ne ovat helposti tunnistettavissa.
	gameNode = {}
	-- Lisätään kentät ja reitit helposti loopattaviin taulukoihin.
	nodeList = {}
	pathList = {}

    for currentPath = 1, #mapData.node do
		gameNode[currentPath] = {}
        for currentStep = 1, #mapData.node[currentPath] do
			gameNode[currentPath][currentStep] = {}
            for currentLevel = 1, #mapData.node[currentPath][currentStep] do
                local data = mapData.node[currentPath][currentStep][currentLevel]
                local level = drawLevel( data, currentPath, currentStep, currentLevel )

                nodeList[#nodeList + 1] = level

				-- Debug pallo, auttaa näkemään miten kaukaa kentät tulevat valituiksi.
                -- local debugArea = display.newCircle( groupMap, level.x, level.y, 36 )
				-- debugArea:setFillColor( 1, 0, 0, 0.25 )

				gameNode[currentPath][currentStep][currentLevel] = level
            end
        end
    end

    nodeList[#nodeList + 1] = startNode
    nodeList[#nodeList + 1] = bossNode

	-- Kun kentät on luotu, niin niihin pystytään viittaamaan mapData:ssa jokaisen
	-- noden kohdalla löytyvien "conn" taulukkojen sijantidatan avulla, jota voidaan
	-- käyttää reittien piirtämiseen kenttien välille.
    for currentPath = 1, #mapData.node do
        for currentStep = 1, #mapData.node[currentPath] do
            for currentLevel = 1, #mapData.node[currentPath][currentStep] do
                local data = mapData.node[currentPath][currentStep][currentLevel]
                local fromNode = gameNode[currentPath][currentStep][currentLevel]
                local toNode

				-- Jos kenttä on viimeinen, niin se yhdistetään bossiin. Tällöin reitin arvoa tulee
				-- kasvattaa yhdellä, ettei se "poistu käytöstä" kun pelaaja saapuu viimeiselle riville.
				local stepOffset = 0
                for l = 1, #data.conn do
                    if data.conn[l][1] == 0 then
                        toNode = startNode
                    elseif data.conn[l][2] == mapData.stepCount+1 then
                        toNode = bossNode
						stepOffset = 1
                    else
                        local toRow = data.conn[l][1]
                        local toCol = data.conn[l][2]
                        local toStep = data.conn[l][3]

                        toNode = gameNode[toRow][toCol][toStep]
                    end

                    drawRoute( fromNode, toNode, currentStep+stepOffset )
                end
			end
		end
	end

	for currentLevel = 1, #nodeList do
		local path = nodeList[currentLevel].route
		if path then
			for currentPath = 1, #path do
				local thisPath = path[currentPath]

				-- Varmista, että jokainen reitti lisätään vain kerran.
				local isDuplicate = false
				for i = 1, #pathList do
					if pathList[i] == thisPath then
						isDuplicate = true
						break
					end
				end

				if not isDuplicate then
					pathList[#pathList + 1] = thisPath
				end
			end
		end
	end
end


function map.setState( state )
	if currentState == state then
		return
	end

	if state == "resume" then
		transition.resume( "map" )
		Runtime:addEventListener( "mouse", onMouseEvent )
		Runtime:addEventListener( "enterFrame", highlightLevel )
	elseif state == "pause" then
		transition.pause( "map" )
		Runtime:removeEventListener( "mouse", onMouseEvent )
		Runtime:removeEventListener( "enterFrame", highlightLevel )
	end

	currentState = state
end


function map.start( parent, sceneParams )
	if not hasStarted then
		hasStarted = true

		if sceneParams and sceneParams.continue then
			prevNode = gameNode[sceneParams.path][sceneParams.row][sceneParams.level]
		else
			prevNode = startNode
		end

		currentRow = prevNode.row
		currentNeighbours = prevNode.connected

		map.setState( "resume" )

		local touchRect = display.newRect( parent, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentWidth )
		touchRect:addEventListener("touch", moveMap )

		touchRect.isHitTestable = true
		touchRect.isVisible = false

		-- Keskitetään kartta ruudulle ja pidetään sen alku paikka tallessa.
		local mapOffsetX = ( display.actualContentWidth - mapWidth ) / 2
		groupMap.x = display.screenOriginX + mapOffsetX
		groupMap.y = 400 - display.screenOriginY
		groupMap.xStart, groupMap.yStart = groupMap.x, groupMap.y

		-- TODO: Tarvitsee varmaan vielä luoda "load" funktiota varten tilanne, että kamera asetetaan alussa oikein.

		-- Kartan piirtoon ja sen liikuttamiseen tarvittavat muuttujat.
		local mapPadding = 100
        local dragDistance = 100

		local xCenter = groupMap.contentBounds.xMin + groupMap.width*0.5
		local yCenter = groupMap.contentBounds.yMin + groupMap.height*0.5

        local background = display.newImageRect( groupMap, "Resources/Images/mapBG.png", groupMap.width + mapPadding*2, groupMap.height + mapPadding*2 )
        background.x, background.y = xCenter - groupMap.x, yCenter - groupMap.y
        background:toBack()

        -- Rajoitetaan kuinka pitkälle karttaa voi ruudulla vetää.
		local mapBounds = groupMap.contentBounds

		local areaLeft = (mapBounds.xMin - screen.minX)
		local areaRight = (screen.maxX - mapBounds.xMax)
		local areaUp = (mapBounds.yMin - screen.minY)
		local areaDown = (screen.maxY - mapBounds.yMax)

		-- Jos kartta on pienempi kuin ruutu, niin ei tarvitse rajoittaa liikettä.
		-- Huom! Mennään oletuksella, että kartta on aina korkeampi kuin näyttö,
		-- niin ylös/alas suuntiin ei tarvitse tehdä erikois-sääntöjä.
		local toLeft = areaLeft - dragDistance
		if areaLeft >= dragDistance then
			toLeft = 0
		end

		local toRight = areaRight - dragDistance
		if areaRight >= dragDistance then
			toRight = 0
		end

		groupMap.dragMinX = groupMap.x + toRight
		groupMap.dragMaxX = groupMap.x - toLeft
		groupMap.dragMinY = groupMap.y + (areaDown - dragDistance)
		groupMap.dragMaxY = groupMap.y - (areaUp - dragDistance)

		local subscale = 0.75
		player = display.newImageRect( groupMap, "Resources/Images/Characters/" .. userdata.player.imageMap, imageWidth, imageHeight )
		player.xScale, player.yScale = subscale, subscale
		player.x = prevNode.x + prevNode.width
		player.y = prevNode.y


	end
end

-- Tuhotaan nykyinen kartta.
function map.destroy()
	if hasStarted then
		hasStarted = false

		map.setState( "pause" )

		gameNode = nil
		nodeList = nil
		pathList = nil
		prevHighlighted = nil

		display.remove( groupMap )
		groupMap = nil
	end
end


return map