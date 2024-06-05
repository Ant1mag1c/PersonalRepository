local character = {}

local characterData = require( "data.characterData" )
local physics = require("physics")
local screen = require("scripts.screen")
local controls = require("scripts.controls")
local vimpain = require("scripts.vimpain")
local vimpainData = require("data.vimpainData")
local collisionData = require( "data.collisionData" )
local loadsave = require( "scripts.loadsave" )

local sheetCache = {}
local characterCache = {}

local random = math.random
local atan2 = math.atan2
local deg = math.deg
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin

local function newSheet( id, data )

    -- Image sheet on jo luotu, niin ladataan se suoraan muistista.
    if sheetCache[id] then
        return sheetCache[id][1], sheetCache[id][2]
    end

    local sheetOptions = table.copy(data.sheetOptions)
    local animSequences = table.copy(data.animSequences)

    -- Ladataan tekstuuri erikseen, jotta voidaan hallinoida sen muistia paremmin
    local imageTexture = graphics.newTexture( { type = "image", filename = data.image, baseDir = system.ResourceDirectory } )
    local sheet = graphics.newImageSheet( data.image, sheetOptions )

    sheetCache[id] = { sheet, animSequences, imageTexture }

    return sheet, animSequences
end

function character.new( parent, x, y, id, isInvulnerable )
    if not id then
        print( "ERROR: character.new ´id´ ei ole määritetty." )
        return false
    end

    local isPlayer = id == "player"
    -- Kaikki "ei pelaajahahmot" ovat vihollisia. Pelaajahahmon kohdalla tämän oikea "id" tulee noutaa tämän hahmodatasta.
    if isPlayer then
        id = loadsave.gamedata.character.name
    end

    local data = characterData[id]
    if not data then
        print( "ERROR: character.new ´id´:tä vastaavaa hahmoa (\"" .. tostring(id) .. "\") ei löydy characterData.lua:sta." )
        return false
    else
        -- Luodaan hahmo datan perusteella
        local sheet, animSequences = newSheet( id, data.sheet )

        local body = display.newGroup()
        parent:insert( body )

        body.sprite = display.newSprite( body, sheet, animSequences )
        body.x, body.y = x or screen.centerX, y or screen.centerY

        body.shadow = display.newImage( body, "assets/images/shadow.png", 0, body.sprite.height*0.5 )
        -- physics.addBody( body.shadow, "dynamic", { radius=4, filter=collisionData.jumpFilter } )
        body.shadow:toBack()

        -- Yleistä dataa pelihahmosta.
        body.isPlayer = isPlayer
        body.isEnemy = not isPlayer
		body.sheetID = id
        body.id = id

        -- Pelihahmon liikkumiseen liittyvää dataa.
        body.direction = "Down" -- TODO: "Down" on vakio, mutta jos peli ladataan, niin se voi olla vaihtunut.
        body.hasStopped, body.movementDisabled, body.holdPosition = true, true, false
        body.state = "idle"
        body.canBeDetected = true

        local collisionFilter
        local dataSource

        if isPlayer then
            collisionFilter = isInvulnerable and collisionData.playerInvulnerable or collisionData.playerFilter
            dataSource = loadsave.gamedata.character

        else
            collisionFilter = collisionData.npcFilter
            dataSource = data.stats

        end

        -- Lisätään dynaamisesti kaikki hahmokohtaiset statsit.
        for key, value in pairs( dataSource ) do
            body[key] = value
        end

        -- Annetaan hahmon physical bodylle oikea collision filter data
        physics.addBody( body, "dynamic", { radius=data.stats.radius, density = 1, friction = 1, filter = collisionFilter } )

        body.isFixedRotation = true
        body._angle = 0
        body._angleInRad = 0

        -- Estä hahmojen fysiikka kroppia nukkumasta. Hahmot liikkuvat normaalisti lähes kokoajan,
        -- niin tällä ei ole siinämäärin merkitystä, mutta hahmot saattavat pysähtyä bugien tai testien aikana.
        body.isSleepingAllowed = false



        local globalCooldown = 300 -- Viive jonka jälkeen ability painikkeen painallus rekisteröidään uudestaan
        local abilityUsedLast = 0

        -- Ability cooldownit eivät tallennu savedatassa, eli pelin tallentaminen ja loadaaminen nollaa cooldownit.
        local abilityCooldown = {}
        local abilityList = {}

        --------------------------------------------------------------------------------------------------

        if isPlayer then
            -- Vain pelaajaan lisättävät funktiot/metodit/muuttujat:

            -- Päivitetään pelaajan käytössä olevien vimpainten lista aina kun toolbar päivittyy.
            function body.updateToolbar()
                abilityList = {}

                for i = 1, #loadsave.gamedata.toolbar do
                    abilityList["ability" .. i] = loadsave.gamedata.toolbar[i]
                end

                body.weapon = abilityList["ability1"]
            end

            body.updateToolbar()

        --------------------------------------------------------------------------------------------------

        else
            -- Vain vihollisiin lisättävät funktiot/metodit/muuttujat:

            -- Pidetään käytössä olevista vihollisista listaa, jotta niiden image sheetit
            -- voidaan myöhemmin poistaa muistista jos niistä ei enää tarvita.
            if not characterCache[id] then
                characterCache[id] = 0
            end
            characterCache[id] = characterCache[id] + 1

            -- body.xStart, body.yStart = body.x, body.y
            body.spawnLoc = { x=body.x, y=body.y }

            function body.getTargetPos( target )
                if target == "spawn" then
                    target = body.spawnLoc
                end

                local dy = target.y - body.y
                local dx = target.x - body.x
                local angleInRad = atan2(dy, dx)
                local angle = deg(angleInRad)
                local currentDistance = sqrt(dx^2 + dy^2)

                body._dx = dx
                body._dy = dy
                body._angleInRad = angleInRad
                body._angle = angle
                body._currentDistance = currentDistance

                return dx, dy, currentDistance
            end


            function body.rayCast( player )
                body.getTargetPos( player )

                local rayRange = 200 -- Vihollisen näköetäisyys
                local angleInRad = body._angleInRad
                local toX = body.x + cos(angleInRad) * rayRange
                local toY = body.y + sin(angleInRad) * rayRange

                -- local line = display.newLine( body.x, body.y, toX, toY )
                -- line.strokeWidth = 4

                local ray = physics.rayCast( body.x, body.y, toX, toY, "unsorted" )

                -- timer.performWithDelay(5, function()
                --     display.remove( line )
                -- end)

                if ray then
                    for _, hit in ipairs( ray ) do
                        -- Tarkastetaan on pelaaja skannattujen objektien joukossa

                        if hit.object == player then
                            return true
                        else
                            return false
                        end
                    end
                end
            end


            local dx, dy, currentDistance
            function body.track( player )
                local rayCast = body.rayCast( player )
                if rayCast then
                    if body.timerLeash then
                        timer.cancel( body.timerLeash )
                        body.timerLeash = nil
                    end
                    body.aggro(player)
                end

                if not player.canBeDetected then
                    body.state = "return"
                end

                if body.state == "return" then
                    dx, dy, currentDistance = body.getTargetPos( "spawn" )

                    local spawnReached = currentDistance and currentDistance < 3
                    if spawnReached then
                        body.state = "idle"
                        dx, dy = 0, 0
                    end

                elseif body.state == "idle" then
                    body.idleBehaviour()
                end

                if dx then
                    local toX = ( dx / currentDistance )
                    local toY = ( dy / currentDistance )

                    body.move( toX * 0.2, toY * 0.2 ) --Temp
                end
            end


            function body.idleBehaviour()
                -- Liikutaan ympäri spawnia
                if not body.randomDirection then
                    body.randomDirection = {
                        x = body.x + random(-40, 40),
                        y = body.y + random(-40, 40),
                    }

                    body.returnTimer = timer.performWithDelay(3000, function()
                        dx, dy = 0, 0
                        body.randomDirection = nil
                        body.returnTimer = nil
                        body.state = "return"
                    end )

                    dx, dy, currentDistance = body.getTargetPos( body.randomDirection )
                end
            end


            function body.aggro(player)
                dx, dy, currentDistance = body._dx, body._dy, body._currentDistance

                if body.state ~= "aggro" then
                    body.state = "aggro"
                end

                if body.attackRange > currentDistance and player.canBeDetected then
                    body.action( body.weapon, "down" )
                end

                if not body.timerLeash then
                    body.timerLeash = timer.performWithDelay( 5000, body.leash )
                end
            end


            function body.leash()
                print("Leash")
                dx, dy, currentDistance = body.getTargetPos( "spawn" )
                body.state = "return"
            end

        end

        --------------------------------------------------------------------------------------------------

        -- Jokaiseen hahmoon lisättävät funktiot/metodit/muuttujat:

        local prevX, prevY = 0, 0

        function body.stop( stopWhat, delay )
            if stopWhat == "controls" then
                if body.timer then
                    timer.cancel( body.timer )
                    body.timer = nil
                end

                body.timer = timer.performWithDelay( delay, function ()
                    body:setLinearVelocity( 0, 0 )
                    body.movementDisabled = true

                end )
            end
        end


        function body.look( dir, isMouse )
			if dir ~= body.direction or body.hasStopped then
				body.sprite:setSequence( "walk" .. dir )

				if not isMouse or (prevX ~= 0 or prevY ~= 0) then
					body.hasStopped = false
					body.sprite:play()
				end
			end

			body.direction = dir
        end


        local shadowIteration = 0
        local iterationsBetweenChange = 10

        function body.move( vx, vy )
            if not body.movementDisabled then
                return
            end

            if body.holdPosition then
                body:setLinearVelocity(0, 0)
                return
            end

            if vx ~= prevX or vy ~= prevY then
                -- x tai y suunta on muuttunut tai se saattoi juuri pysähtyä, eli nyt voi olla tarve päivittää hahmon animaatiota
                if vx == 0 and vy == 0 then
                    body.sprite:pause()
					body.hasStopped = true
                else
					if body.hasStopped or not body.isMouseButtonDown then
						if vx > 0 then
							body.look("Right")
						elseif vx < 0 then
							body.look("Left")
						elseif vy > 0 then
							body.look("Down")
						elseif vy < 0 then
							body.look("Up")
						end
					end
                end
            end

            shadowIteration = shadowIteration + 1

			-- Päivitetään hahmon liikkumista jatkuvasti (myös sen ollessa paikallaan).
			body:setLinearVelocity(vx*body.movementSpeed, vy*body.movementSpeed)

            if shadowIteration >= iterationsBetweenChange then
                shadowIteration = 0

                body.shadow.alpha = random( 65, 80 )*0.01
                body.shadow.xScale, body.shadow.yScale = random( 99, 101 )*0.01, random( 99, 101 )*0.01
            end

            prevX, prevY = vx, vy
        end

		function body.action( action, phase )
            if phase == "down" then
                local currentTime = system.getTimer()

                if abilityUsedLast + globalCooldown > currentTime then

                else
                    -- Haetaan pelaajan toolbarista näppäintä vastaava vimpain. Jos vimpainta ei löydy,
                    -- niin silloin tod näk näppäintä ei annettu, vaan action on suoraan vimpaimen nimi.
                    local vimpainName = abilityList[action] or action
                    local vimpainUsed = vimpainData[vimpainName]

                    if not vimpainUsed then
                    else
                        if not abilityCooldown[vimpainName] or abilityCooldown[vimpainName] + vimpainUsed.cooldown <= currentTime then
                            abilityCooldown[vimpainName] = currentTime
                            abilityUsedLast = currentTime

                            vimpain[vimpainName](body, actionRepeated)
                            ---------------------------------------------------------------------

                            -- TODO: Tulisiko kääntyminen vimpainten yhteydessä tehdä paremmaksi?
                            local angle = body._angle

                            local direction
                            if ( -135 >= angle or angle > 135 ) then
                                direction = "Left"
                            elseif ( -45 < angle and angle <= 45 ) then
                                direction = "Right"
                            elseif ( -135 < angle and angle <= -45 ) then
                                direction = "Up"
                            elseif ( 135 >= angle and angle > 45 ) then
                                direction = "Down"
                            end

                            -- Päivitä hahmon suuntaa vain jos se on muuttunut.
                            if direction ~= body.direction then
                                body.look( direction, true )
                            end

                            ---------------------------------------------------------------------
                        else
                        end
                    end
                end
            end
        end

        -- Funktio toistaiseksi kommentoitu kuin aggro asetukset eivät ole käytössä
        function body.takeHit( self, damageTaken )
            print(self.id .. "-" .. damageTaken .. " hp")
            self.hitTaken = true

            self.health = self.health - damageTaken

            self.isDead = self.health < 1

            if not isPlayer then
                if not self.isDead then
                    -- self.aggro()
                else
                    self.isVisible = false
                    -- self.isBodyActive = false
                end
            else
                -- Pelaajalle tapahtuu kuollessaan jotain muuta

            end
        end

        function body:finalize( event )
            if type( body ) == "table" then
                -- print( "Finalizing:", self )

                if body.timer then
                    timer.cancel( body.timer )
                    body.timer = nil
                end
                if body.returnTimer then
                    timer.cancel( body.returnTimer )
                    body.returnTimer = nil
                end
                if body.timerLeash then
                    timer.cancel( body.timerLeash )
                    body.timerLeash = nil
                end

                if isPlayer then
                    controls.stop()
                else
                    if characterCache[body.sheetID] then
                        characterCache[body.sheetID] = characterCache[body.sheetID] - 1
                    end

                    if not characterCache[body.sheetID] or characterCache[body.sheetID] <= 0 then
                        if sheetCache and sheetCache[body.sheetID] and sheetCache[body.sheetID][3] then
                            sheetCache[body.sheetID][3]:releaseSelf()
                            sheetCache[body.sheetID] = nil
                        end
                    end
                end
            end
        end
        body:addEventListener( "finalize" )

        return body
    end
end

return character