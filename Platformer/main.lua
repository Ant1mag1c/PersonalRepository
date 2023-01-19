local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )

-- physics.setDrawMode( "hybrid" )

-- local backGroup = display.newGroup()
-- local mainGroup = display.newGroup()
-- local uiGroup = display.newGroup()
-- local endGameGroup = display.newGroup()

local controller = require("Scripts.Controller")


local enemyT = { }

--Types are: fire, water, air, earth
resistance = "neutral"


local bFire = { type="image", filename="Images/fire.png" }
local bWater = { type="image", filename="Images/water.png" }
local bAir = { type="image", filename="Images/air.png" }
local bEarth = { type="image", filename="Images/earth.png" }


local groupBack, groupGame, groupUI = display.newGroup(), display.newGroup(), display.newGroup()

local x, y = display.contentCenterX, display.contentCenterY

local player, enemy
local backGround = display.newImageRect(groupBack, "Images/backGround.png", 850, 500 )
backGround.x, backGround.y = x,y

local hp1 = display.newImageRect( groupUI, "Images/health.png",  50, 50 )
local hp2 = display.newImageRect( groupUI, "Images/health.png",  50, 50 )
local hp3 = display.newImageRect( groupUI, "Images/health.png",  50, 50 )
      hp1.x, hp1.y, hp2.x, hp2.y, hp3.x, hp3.y = -230, 30, -230, 80, -230, 130

      
local moveSpeed = 200
local score = 0
local hp = 3
local gotDamage = false


local scoreText = display.newText( groupUI, "Score: " .. score, x, 20, native.systemFont, 36 )
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

function spawnEnemy()
enemy = display.newImageRect( groupGame, "Images/fire.png", 80, 80 )
enemy.x, enemy.y = x+390, y+math.random(-200, 200)
table.insert( enemyT, enemy )
local tarX, tarY = player.x - enemy.x, player.y - enemy.y
local angle = math.atan2( tarX, tarY)
physics.addBody( enemy, {radius=20, isBullet=true, isSensor=true } )
enemy:setLinearVelocity( -x, tarY*0.5 )
local enemyType = math.random(4)
    if enemyType == 1 then    
       enemy.fill, enemy.name = bFire, "fire"
    elseif enemyType == 2 then
           enemy.fill, enemy.name = bWater, "water"
    elseif enemyType == 3 then
           enemy.fill, enemy.name = bAir, "air"
    elseif enemyType == 4 then
           enemy.fill, enemy.name = bEarth, "earth" 
    end
end

local function restorePlayer()
    if player then
    player.isBodyActive = false
    transition.to( player, { x=x, y=y, time=100 } )

        transition.to(player, {alpha=1, time=3000, 
        onComplete = function()
            player.isBodyActive = true
            dead = false
            end
        } )
    end    
end



--Kuunnellaan jos nappi on valittu niin muutetaan alphaa
local function gameLoop()
    spawnEnemy()

    for i = #enemyT, 1, -1 do
        local thisEnemy = enemyT[i]
            if thisEnemy.x <= x-400 or thisEnemy.x >= x+400 or thisEnemy.y >= y+230 or thisEnemy.y <= y-400
        then
            display.remove( thisEnemy )
			table.remove( enemyT, i )
            end
    end
end

local function textUpdate()
    if gotDamage == true then
        if hp == 2 then
        hp3:removeSelf()
        elseif hp == 1 then
        hp2:removeSelf()
        elseif hp == 0 then
            controller.stop(player)    
            hp1:removeSelf()
            player:removeSelf()
            timer.pause ("spawner")
        end
        gotDamage = false
    end      
    scoreText.text = "Score: " .. score  
end
--EI TOIMI
local function update()
    -- if player then
        if  player.x <= x-300 and dead == false or
            player.x >= x+450 and dead == false or
            player.y >= y+200 and dead == false or
            player.y <= y-400 and dead == false then
            print("dead")    
            -- dead = true
            -- player.alpha=0
            -- timer.performWithDelay( 1000, restorePlayer)


            textUpdate()
        -- end
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
        score = score + 10
        textUpdate()

        else
            gotDamage = true
            hp = hp - 1
            textUpdate()
        end
    end
end

gameLoopTimer = timer.performWithDelay( 600, gameLoop, 0, "spawner"  )

function buttonUpdate()
    if resistance == "fire" then
        local effect1 = display.newImageRect( groupUI,"Images/firebutton.png", 60, 60 )
        effect1.x, effect1.y, effect1.alpha = fire.x, fire.y, 1
        transition.to( effect1, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 1, 0.4, 0.4, 0.4
        player.fill = { type="image", filename="Images/pfire.png" }  

    elseif resistance == "water" then
        local effect2 = display.newImageRect( groupUI,"Images/waterbutton.png", 60, 60 )
        effect2.x, effect2.y, effect2.alpha = water.x, water.y, 1
        transition.to( effect2, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 1, 0.4, 0.4
        player.fill = { type="image", filename="Images/pwater.png" }

    elseif resistance == "air" then
        local effect3 = display.newImageRect( groupUI,"Images/airbutton.png", 60, 60 )
        effect3.x, effect3.y, effect3.alpha = air.x, air.y, 1
        transition.to( effect3, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 0.4, 1, 0.4
        player.fill = { type="image", filename="Images/pair.png" }

    elseif resistance == "earth" then
        local effect4 = display.newImageRect( groupUI,"Images/earthbutton.png", 60, 60 )
        effect4.x, effect4.y, effect4.alpha = earth.x, earth.y, 1
        transition.to( effect4, {alpha=0, time=800, width=100, height=100} )
        fire.alpha, water.alpha, air.alpha, earth.alpha = 0.4, 0.4, 0.4, 1
        player.fill = { type="image", filename="Images/pearth.png" }

    end
end

player.collision = onCollision
player:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", update)












