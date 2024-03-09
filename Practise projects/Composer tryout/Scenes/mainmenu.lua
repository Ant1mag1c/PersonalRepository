local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()

local sceneParams
local thisScene = composer.getSceneName( "current" )

-- DisplayObjects
local button1, button2, button3



-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function handleButton(event)
    local target = event.target

    if target.id == "next" then
        print("next scene")
    end


end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    sceneParams = event.params
    print("#" .. thisScene)


    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    -- button1 = widget.newButton( {parent = sceneGroup, id = "prev", label="prev", x=20, y=display.contentCenterY, onRelease=handleButton,  } )
    button2 = widget.newButton( {parent = sceneGroup, id = "next", label="next", x=(display.contentWidth) - 20, y=display.contentCenterY, onRelease=handleButton} )
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene