


local composer = require("composer")

-- Seed the random number generator
math.randomseed( os.time() )

composer.gotoScene( "menu" )


  --Group for UI (score etc)

local background = display.newImageRect(backGroup, "Images/background.png", 800, 1400)
      background.x, background.y = display.contentCenterX, display.contentCenterY




local function dragShip( event )

    local ship = event.target
    local phase = event.phase
-- Set touch focus on the ship
    if phase == "began" then
    display.currentStage:setFocus( ship )
-- Store initial offset position
    ship.touchOffsetX = event.x - ship.x
    ship.touchOffsetY = event.y - ship.y

        elseif phase == ("moved") then
-- Move the ship to new touch location
            ship.x = event.x - ship.touchOffsetX
            ship.y = event.y - ship.touchOffsetY

                elseif phase == ("ended") then
                    display.currentStage:setFocus(nil)
    end
    return true --Prevent touch propagation to underlying objects
end



local function gameLoop()
    -- Create new asteroid
    createAsteroid()
    -- print(asteroidsTable[1])
    -- Remove asteroid which are drifted off screen
        for i = #asteroidsTable, 1, -1 do
        local thisAsteroid = asteroidsTable[i]


        if  thisAsteroid.x < -100 or
            thisAsteroid.x > display.contentWidth + 100 or
            thisAsteroid.y < -100 or
            thisAsteroid.y > display.contentHeight + 100 then

                display.remove( thisAsteroid )
                table.remove( asteroidsTable, i)

        end
    end
end




local function restoreShip()

    ship.IsbodyActive = false
    ship.x, ship.y = display.contentCenterX, display.contentCenterY + 350
    -- Fade in the ship
        transition.to( ship, { alpha=1, time=4000, onComplete = function()
        ship.isBodyActive = true
        died = false
        end
    } )
end

local function onCollision( event )

    if event.phase == "began" then
        local obj1, obj2 = event.object1, event.object2
        -- print( obj1.myName, obj2.myName )

        if obj1.myName == "laser" and obj2.myName == "asteroid" or
           obj1.myName == "asteroid" and obj2.myName == "laser" then

           display.remove( obj1 )
           display.remove( obj2 )

            for i = #asteroidsTable, 1, -1 do
                if asteroidsTable[i] == obj1 or asteroidsTable[i] == obj2 then
                table.remove( asteroidsTable, i )
                break

                end
            end


            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score



        elseif  obj1.myName == "player" and obj2.myName == "asteroid" or
                obj1.myName == "asteroid" and obj2.myName == "player" then

            if  died == false then
                died = true

                lives = lives - 1
                livesText.text = "Lives: " .. lives

                if lives == 0 then
                    display.remove( ship )

                else ship.alpha = 0
                    timer.performWithDelay( 1000, restoreShip )

                end
            end
        end
    end
end




