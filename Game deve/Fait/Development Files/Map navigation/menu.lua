local menu = {}



function openMenu()
    local x, y = display.contentCenterX, display.contentCenterY
    if sceneLayer == "map" or sceneLayer == "options" or sceneLayer == "battle" then
        sceneLayer = "menu"
        print( "Menu opened" )

        local newMenu = display.newGroup()

        local function closeMenu( event )
            if event.phase == "ended" and sceneLayer == "menu" then
                timer.performWithDelay( 20, function()
                display.remove( newMenu )
                print("Menu closed")
                sceneLayer = "map" end )
            end
        end

        local function saveGame( event )
            if event.phase == "ended" and sceneLayer == "menu" then
                display.remove( newMenu )
                print( "Your game is now saved" )
                print( "Your game is now closed" )
                timer.performWithDelay( 10, function() sceneLayer = "map" end )
            end
        end

        local background = display.newImageRect( newMenu, "Images/menu.png", 250, 300 )
            background.x, background.y = x, y

        local menuText = display.newText( newMenu, "In-game menu", x, y-140, native.systemFont, 20 )

        local close = display.newText( newMenu, "close", x, y+140, native.systemFont, 20 )
            close:addEventListener( "touch", closeMenu )

        local options = display.newText( newMenu, "options", x, y, native.systemFont, 20 )
            options:addEventListener( "touch", openOptions )

        local quit = display.newText( newMenu, "save&quit", x, y+100, native.systemFont, 20 )
            quit:addEventListener( "touch", saveGame )

    end

end


return menu