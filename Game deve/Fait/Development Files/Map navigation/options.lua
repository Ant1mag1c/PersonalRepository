local options = {}



function openOptions( event )
    local x, y = display.contentCenterX, display.contentCenterY

    if event.phase == "ended" and sceneLayer == "menu" then
        print( "Options opened" )
        sceneLayer = "options"
        newOptions = display.newGroup()

        local function closeOptions( event )
            if event.phase == "ended" and sceneLayer == "options" then
                timer.performWithDelay( 20, function()
                print( "Options closed" )
                display.remove( newOptions )
                openMenu()
                sceneLayer = "menu" end  )
            end
        end

        local background = display.newImageRect( newOptions, "Images/options.png", 250, 300 )
            background.x, background.y = x, y

        local title = display.newText( newOptions, "Options", x, y-140, native.systemFont, 20 )

        local close = display.newText( newOptions, "close", x, y+140, native.systemFont, 20 )
            close:addEventListener( "touch", closeOptions )

        return newOptions
    end
end


return options