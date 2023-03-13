local map = {}


--TODO: Kenttien sisällön määrittäminen - onko kenttä metsää, peltoa vai vettä, tai mikä event kentässä on (vihollinen, random event, kauppa, jne.)
--TODO: Kartan muistaminen (eli map.generate outputin tallennus tiedostoon)

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
		print( "currentRow:", currentRow, "target.row:", target.row )

		if target.row == currentRow + 1 then
			local isConnected = false
			for i = 1, #target.connected do
				if target.connected[i] == prevNode then
					isConnected = true
					break
				end
			end
			print( isConnected and "target is connected" or "target is not connected" )

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


    --Automaattisesti lasketut map muuttujat
    local mapWidth = colWidth*pathCount
    local colWidthHalf = colWidth * 0.5
    local levelVarX = (colWidthHalf - levelWidth - levelPad*2)*0.5
    local levelMaxY = stepHeight - levelHeight*0.5 - levelPad
    local levelCount = 0

    -- Keskitetään kartta ruudulle.
    local mapOffsetX = ( display.actualContentWidth - mapWidth ) / 2
    groupMap.x = display.screenOriginX + mapOffsetX
    groupMap.y = 400



    local node = {}
    node.stepCount = stepCount
    node.start = { x=mapWidth/2, y=stepHeight, type = "start", loc = {0,0,0} }
    node.boss =  { x=mapWidth/2, y=-(stepCount+1)*stepHeight, type = "end", loc = {stepCount+1, stepCount+1, stepCount+1} }

	-- TODO: Vaihda for looppien indeksien nimet johonkin paremmin kuvaileviin. Esim. for i = 1, pathCount do-loopissa i (eli indeksi i),
	-- ei kuvaile mitä loopissa tehdään, mutta jos se olisikin esim. for currentPath = 1, pathCount do, niin currentPath kertookin heti
	-- paljon enemmän siitä, että missä mennään ja mitä loopissa tapahtuu. Tämä pätee vielä enemmän kun taulukoita alkaa olemaan useampia
	-- sisäkkäin. Kuukauden kuluttua kukaan ei enää muista, että "mikä node[i][j][k] oikein on?", mutta paremmat ja kuvailevammat nimet auttaa.
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
				-- TODO: Samalla kun muutetaan for looppien indeksien nimiä, niin on myös hyvä muuttaa muiden huonosti kuvaavien muuttujien nimiä.
				-- xBall ja ball esim. kuvailivat kenttiä kun ne olivat palloja, mutta nyt esim. level olisi paljon parempi ja kuvailevampi nimi.
                local levelX

                if levelsInStep == 1 then
                    levelX = x + colWidthHalf
                else
                    levelX = x + colWidthHalf / 2 + (currentLevel-1) * colWidthHalf
                end

                levelX = levelX + math.random(-levelVarX, levelVarX)

                local level = { x=levelX, y=y, type = "TBD", loc = {currentPath,currentStep,currentLevel} }
                levelCount = levelCount + 1

                for l = 1, connCount do

                    local prev = node[currentPath][currentStep-1] and node[currentPath][currentStep-1][l] or node.start
                    local continue = not (buildConnection and not buildConnection[currentLevel][l])

                    if continue then
                        addRouteData(level, prev)
                    end
                end

                node[currentPath][currentStep][currentLevel] = level
            end
        end
    end

    -- Kun kentät luotu niin randomoidaan niille sisältö
    -- TODO:
    print("levelCount", levelCount)

    for paths = 1, pathCount do
        for j = 1, stepCount do
            for k = 1, #node[paths][j] do




            end
        end
    end









	-- TODO: Tässä ja muuallakin tapahtuu jänniä asioita, ja me toivonmukaan muistetaan vielä mitä, mutta ensi kuussa tilanne voikin olla eri.
	-- Tälläisiin paikkoihin olisi hyvä lisätä aina kommentti, että "miksi tässä tehdään näin?", jotta muutkin koodarit pysyvät kanssa kärryillä.
    for currentPath = 1, pathCount do
        for currentRow = 1, #node[currentPath][stepCount] do
            local prev = node[currentPath][stepCount][currentRow]

            addRouteData(node.boss, prev)
        end
    end

    if stepCount > 2 then
        for currentRow = 1, pathCount-1 do
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
            local fromA = node[currentRow][rowA][#node[currentRow][rowA]]
            local toA = node[currentRow+1][rowA+rowOffsetA][1]

            addRouteData(fromA, toA)

            if rowB then
                local rowOffsetB = math.random() < 0.5 and -1 or 1
                local fromB = node[currentRow][rowB][#node[currentRow][rowB]]
                local toB = node[currentRow+1][rowB+rowOffsetB][1]

                addRouteData(fromB, toB)
            end
        end
    end

    for currentPath = 1, pathCount do
        for currentRow = 1, stepCount do
            for currentStep = 1, #node[currentPath][currentRow] do
                local connected = node[currentPath][currentRow][currentStep].connected

                node[currentPath][currentRow][currentStep].conn = {}
                for l = 1, #connected do
                    node[currentPath][currentRow][currentStep].conn[l] = { connected[l].loc[1], connected[l].loc[2], connected[l].loc[3] }
                end
            end
        end
    end

	-- Poistetaan taulukoista tarpeeton data ennen kuin taulukko palautetaan funktiosta.
	-- Tämä tekee datasta helppolukuisempaa ja vähentää tallennettujen tiedostojen kokoa.
	for currentPath = 1, pathCount do
        for currentRow = 1, stepCount do
            for currentStep = 1, #node[currentPath][currentRow] do
                node[currentPath][currentRow][currentStep].loc = nil
                node[currentPath][currentRow][currentStep].connected = nil
            end
        end
    end
    node.start.connected = nil
    node.start.loc = nil
    node.boss.connected = nil
    node.boss.loc = nil

    return node
end

-- Piirretään kartta annetuiden tietojen mukaan.
function map.render( mapData )
    if type(mapData) ~= "table" then
        print( "WARNING: render() expected table, got ".. type(mapData) )
        return
    end

    -- Start node on aina kartan pohjalla.
    startNode = display.newCircle( groupMap, mapData.start.x, mapData.start.y, 20 )
    startNode.type = mapData.start.type
    startNode:setFillColor(0,1,0)
    startNode:addEventListener("touch", movePlayer)
    startNode.row = 0
    prevNode = startNode


    local bossNode = display.newCircle( groupMap, mapData.boss.x, mapData.boss.y, 20 )
    bossNode.type = mapData.boss.type
    bossNode:setFillColor(1,0,0)
    bossNode:addEventListener("touch", movePlayer)
    bossNode.row = mapData.stepCount + 1

	-- Asetetaan kaikki kentät tuttuun node taulukkoon, jolloin ne löytyvät
	-- samoilla tavoin map.generate() ja map.render() funktioiden taulukoissa.
	local node = {}
    for currentPath = 1, #mapData do
		node[currentPath] = {}
        for currentRow = 1, #mapData[currentPath] do
			node[currentPath][currentRow] = {}
            for currentStep = 1, #mapData[currentPath][currentRow] do
                local data = mapData[currentPath][currentRow][currentStep]
                local level = display.newCircle( groupMap, data.x, data.y, 20 )
                level.type = data.type
                level:addEventListener("touch", movePlayer)
                level.row = currentRow

				node[currentPath][currentRow][currentStep] = level
            end
        end
    end

	-- Kun kentät on luotu, niin niihin pystytään viittaamaan mapData:ssa jokaisen
	-- noden kohdalla löytyvien "conn" taulukkojen sijantidatan avulla, jota voidaan
	-- käyttää reittien piirtämiseen kenttien välille.
    for currentPath = 1, #mapData do
        for currentRow = 1, #mapData[currentPath] do
            for currentStep = 1, #mapData[currentPath][currentRow] do
                local data = mapData[currentPath][currentRow][currentStep]
                local fromNode = node[currentPath][currentRow][currentStep]
                local toNode

                for l = 1, #data.conn do
                    if data.conn[l][1] == 0 then
                        toNode = startNode
                    elseif data.conn[l][2] == mapData.stepCount+1 then
                        toNode = bossNode
                    else
                        -- TODO: Korjaa muuttujien nimet (Path,Row,Level)

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