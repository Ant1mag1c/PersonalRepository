local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )

-- physics.setDrawMode( "hybrid" )

local controller = require("Scripts.Controller")


local enemyT = { }

--Types are: fire, water, air, earth
resistance = "neutral"


local bFire = { type="image", filename="Images/fire.png" }


local groupBack, groupGame, groupUI = display.newGroup(), display.newGroup(), display.newGroup()
-- local groupGame = display.newGroup()
-- local groupUI = display.newGroup()
local x, y = display.contentCenterX, display.contentCenterY

local player, enemy

local backGround

local moveSpeed = 200
-----------------------------------------------------------------------------

player = display.newImageRect( groupGame, "Images/player.png", 80, 80 )
player.x, player.y = x, y+100
physics.addBody(player, {radius=40, })

local fire  = display.newImageRect( groupUI, "Images/firebutton.png", 60 ,60 )
      fire.x, fire.y, fire.name = x+300, y+80, "fire"

local water = display.newImageRect( groupUI, "Images/waterbutton.png", 60, 60 )
      water.x, water.y, water.name = x+300, y+200, "water"

local air = display.newImageRect( groupUI, "Images/airbutton.png", 60, 60 )
      air.x, air.y, air.name = x+230, y+135, "air"

local earth = display.newImageRect( groupUI, "Images/earthbutton.png", 60, 60 )
      earth.x, earth.y, earth.name = x+370, y+135, "earth"


controller.start(player)

function player.move(self, x, y )
    self:setLinearVelocity( x*moveSpeed, y*moveSpeed)
end

local function spawnEnemy()
enemy = display.newImageRect( groupGame, "Images/fire.png", 60, 60 )
table.insert( enemyT, enemy )
physics.addBody( enemy, {radius=16, isBullet=true, isSensor=true } )
local enemyType = math.random( 1 )
    if enemyType == 1 then
        enemy.x, enemy.y = x, y
        enemy.fill, enemy.name = bFire, "fire"
        enemy:setLinearVelocity( -150 , 0 )
    else
        enemy.x, enemy.y = x+200, y
        enemy.fill, enemy.name = bFire, "fire"
        enemy:setLinearVelocity( -80 , 0 )
    end
end



--Kuunnellaan jos nappi on valittu niin muutetaan alphaa
local function gameLoop()
    spawnEnemy()

    for i = #enemyT, 1, -1 do
        local thisEnemy = enemyT[i]

        if thisEnemy.x <= x-400 or thisEnemy.x >= x+400 or thisEnemy.y >= y+230 or thisEnemy.y <= y-130
        then
            display.remove( thisEnemy )
			table.remove( enemyT, i )
        end

    end
end

local function onCollision( event, player)
    if event.phase == "began" then
        display.remove(event.other)

        for i = #enemyT, 1, -1 do
            if enemyT[i] == event.other then
            table.remove( enemyT, i )
            break
            end
        end

            if event.other.name == resistance then
            print("resist")



        else
            print("damage")

            end
    end
end

gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0  )

function buttonUpdate()
    if resistance == "fire" then
        local effect1 = display.newImageRect( groupUI,"Images/firebutton.png", 60, 60 )
        effect1.x, effect1.y, effect1.alpha = fire.x, fire.y, 1
        transition.to( effect1, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 1, 0.4, 0.4, 0.4

    elseif resistance == "water" then
        local effect2 = display.newImageRect( groupUI,"Images/waterbutton.png", 60, 60 )
        effect2.x, effect2.y, effect2.alpha = water.x, water.y, 1
        transition.to( effect2, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 1, 0.4, 0.4

    elseif resistance == "air" then
        local effect3 = display.newImageRect( groupUI,"Images/airbutton.png", 60, 60 )
        effect3.x, effect3.y, effect3.alpha = air.x, air.y, 1
        transition.to( effect3, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 0.4, 1, 0.4

    elseif resistance == "earth" then
        local effect4 = display.newImageRect( groupUI,"Images/earthbutton.png", 60, 60 )
        effect4.x, effect4.y, effect4.alpha = earth.x, earth.y, 1
        transition.to( effect4, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 0.4, 0.4, 1

    end
end





player.collision = onCollision
player:addEventListener("collision", onCollision)












