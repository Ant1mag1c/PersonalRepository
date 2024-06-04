local t = {}
-- Hold mouse1 to continously print mouse cordinates or
--press mouse2 to measure distance travelled

function t.getDistance( target1, target2 )
    local dx = target1.x - target2.x
    local dy = target1.y - target2.y
    -- local angleInRad = math.atan2(dy, dx)
    -- local angle = math.deg(angleInRad)
    local distance = math.sqrt( dx^2 + dy^2 )

    return distance
end

function t.measure()
    local startLoc = { x = 0, y = 0}
    local endLoc = {x = 0, y = 0}
    local printDistance

    local function onMouseEvent( event )
        if event.isPrimaryButtonDown then
            print( "X:", math.floor(event.x), "Y:", math.floor(event.y))
        end

        if event.isSecondaryButtonDown then
            if event.type == "down" then
                startLoc.x, startLoc.y = event.x, event.y
                printDistance = true
            end

        elseif event.type == "up" then
            endLoc.x, endLoc.y = event.x, event.y
            local distance = t.getDistance( endLoc, startLoc )

            if printDistance then
                print("Distance Traveled:", math.floor(distance) .. "px")
            end
            printDistance = false
        end


        return true
    end
    Runtime:addEventListener("mouse", onMouseEvent)
end

return t