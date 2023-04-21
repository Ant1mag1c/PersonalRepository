local shop = {}


function openShop( event )
    local x, y = display.contentCenterX, display.contentCenterY
    if event.phase == "ended" and sceneLayer == "map" then
        sceneLayer = "shop"
        print( "Shop opened" )

        local newShop = display.newGroup()

        local function closeShop( event )
            if event.phase == "ended" then
                timer.performWithDelay( 20, function()
                print( "Shop closed" )
                display.remove( newShop )
                sceneLayer = "map"             end )
            end
        end

        local background = display.newImageRect( newShop, "Images/shop.png", 480, 320 )
            background.x, background.y = x, y

        local exitShop = display.newText( newShop, "Leave", x-200, y+140, native.systemFont, 20 )
            exitShop:setFillColor(0,0,0)
            exitShop:addEventListener( "touch", closeShop )

        return newShop
    end
end

return shop