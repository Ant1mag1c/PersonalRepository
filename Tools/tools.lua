local t = {}
-- Hold mouse1 to continously print mouse cordinates or
--press mouse2 to measure distance travelled


function t.measure()
    local startX, startY = 0, 0
    local endX, endY = 0, 0
    local printDistance

    local function onMouseEvent( event )
        if event.isPrimaryButtonDown then
            print( "X:", math.floor(event.x), "Y:", math.floor(event.y))
        end

        if event.isSecondaryButtonDown then
            if event.type == "down" then
                startX, startY = event.x, event.y
                printDistance = true
            end

        elseif event.type == "up" then
            endX, endY = event.x, event.y
            local distance = math.sqrt((endX - startX)^2 + (endY - startY)^2)

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