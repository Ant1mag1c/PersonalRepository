local event = {}
local newEvent




function openEvent( event )
    local x, y = display.contentCenterX, display.contentCenterY
        if event.phase == "ended" and sceneLayer == "map" then
            sceneLayer = "event"
            print( "Event opened" )

            local newEvent = display.newGroup()

            local function closeEvent( event )
                if event.phase == "ended" then
                    timer.performWithDelay( 20, function()
                        print( "Event closed" )
                        display.remove( newEvent )
                        sceneLayer = "map"         end )
                end
            end

            local background = display.newImageRect( newEvent, "Images/event.png", 480, 320 )
                background.x, background.y = x, y

            local close = display.newText( newEvent, "Close", x-200, y+140, native.systemFont, 20 )
                close:setFillColor( 0,0,0 )
                close:addEventListener( "touch", closeEvent )

            return newEvent
        end
end

return event