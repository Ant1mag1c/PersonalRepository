-- TODO: Luo oma moduuli asteiden sekä etäisyyksien laskennalle. Lohari sekä tulipallot hyödyntävät samaa

local gamedata = require( "Scripts.gamedata" )
local projectile = require( "Scripts.projectile" )
local calc = require( "Scripts.calc" )

local t = {}

function t.new(parent, x, y)
    local imageSheet  = graphics.newImageSheet("Images/dragon.png", { width=144, height=128, numFrames=12 } )

    local dragon = display.newSprite(imageSheet, { start = 4, count = 3, time = 500 })
    parent:insert( dragon )
    dragon.x, dragon.y = x, y
    dragon:play()

    -- dragon.type = "enemy"
    dragon.anchorY = 0.5
    dragon.anchorX = 0.5

    physics.addBody(dragon, { isSensor = true, bodyType = "dynamic" })
    dragon.gravityScale = 0

    gamedata.dragonX = dragon.x
    gamedata.dragonY = dragon.y

    local flySpeed = 300

    function dragon.start( vx )
        dragon:setLinearVelocity( vx * flySpeed, 0 )
        dragon.xScale = vx
    end

    function dragon.stop()
        dragon:setLinearVelocity( 0 )
    end

    function dragon.shoot( direction )
        local offset = dragon.width * 0.3
        local fromX = direction == 1 and (dragon.x + offset) or (dragon.x - offset)

        local fireball = projectile.new( parent, fromX, dragon.y+20 , gamedata.playerRef )
        fireball.anchorX = 0.25

        return fireball
    end

    -- end

    dragon.scanRange = gamedata.scanRange or 800

    -- Loharin tulee nähdä pelaaja ennekuin se alkaa ampuaa
    function dragon.scan( player )
        local result = calc.getAngle( dragon, player )

        local _angle = result.angleInRad

        local toX = dragon.x + math.cos(_angle) * dragon.scanRange
        local toY = dragon.y + math.sin(_angle) * dragon.scanRange

        local hits = physics.rayCast( dragon.x, dragon.y, toX, toY, "unsorted" )

        dragon.playerInRange = false

        if ( hits ) then
            for k,v in ipairs( hits ) do
                dragon.playerInRange = v.object.id == "player"
                -- Muut objektit eivät estä loharia näkemästä pelaajaa
                if dragon.playerInRange then
                    break
                end
            end
        end

        if gamedata.printScanResult then
            print(dragon.playerInRange)
        end

        if gamedata.scanLine then
            local line = display.newLine( parent, dragon.x, dragon.y, toX, toY )

            timer.performWithDelay( 2, function()
                display.remove(line)
                line = nil
            end )
        end
    end

    if not gamedata.dragonFreezed then
        dragon.start( 1 )
    end

    return dragon
end

return t