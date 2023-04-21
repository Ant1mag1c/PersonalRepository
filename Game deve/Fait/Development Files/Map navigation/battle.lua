--Mietteet:
--1. Menu ei nyt parhaillaan toimi battle scenessä

local composer = require( "composer" )
local scene = composer.newScene()
local sceneName = "Battle"

local menu = require("menu")
local options = require("options")

sceneLayer = "battle"



function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    local x, y = display.contentCenterX, display.contentCenterY



    if ( phase == "will" ) then
        print(sceneName .. " is on the screen" )

            if sceneLayer == "battle" then
                local groupGame = display.newGroup()
                local groupUI = display.newGroup()

                local function exitBattle( event )
                    if event.phase == "ended" then
                        display.remove( groupGame )
                        display.remove( groupUI )
                        composer.gotoScene( "map", { time=500, effect="crossFade" } )
                        sceneLayer = "map"

                    end
                end


                local background = display.newRect( groupGame, x, y, 600, 640 )

                local title = display.newText( groupGame, "Battle scene", x, y-140, native.systemFont, 20 )
                                    title:setFillColor(0,0,0)

                local exit = display.newText( groupGame, "Exit battle", x+100, y+140, native.systemFont, 20 )
                    exit:setFillColor(0,0,0)
                    exit:addEventListener( "touch", exitBattle )

                local menuT = display.newText( groupUI, "Menu", x-230, y-140, native.systemFont, 20 )
                    menuT:setFillColor(0,0,1)
                    menuT:addEventListener( "touch", function( event )
                        if event.phase == "ended" then openMenu() end end )




            end

    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        print(sceneName .. " scene removed" )
        -- Code here runs when the scene is on screen (but is about to go off screen)
        composer.removeScene( "battle" )

    elseif ( phase == "did" ) then
        print(sceneName .. " is hidden" )


    end
end

-- -- destroy()
-- function scene:destroy( event )

-- local sceneGroup = self.view
-- -- Code here runs prior to the removal of scene's view

-- end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

--DUMPSTER SECTION
---------------------------------------------------------------------------------------
-- local function createTile(name, tileX, tileY,  font, size)
--     local newTile = display.newText(name, x, y, font, size)
--         newTile:setFillColor(0,0,0)
--         newTile.x = tileX
--         newTile.y = tileY
--         newTile.name = name
--         newTile.font = font
--         newTile.size = size
--         print(newTile.name)
--     end

    -- local shopTile = createTile( "Shop", 120, 220, native.systemFont, 16 )
        -- shopTile:addEventListener( "touch", createShop)

    -- local eventTile = createTile( "Event", 180, 210, native.systemFont, 16 )
        -- eventTile:addEventListener( "touch", createEvent)

    -- local battleTile = createTile( "Battle", 240, 190, native.systemFont, 16 )
        -- battleTile:addEventListener( "touch", enterBattle)
        -- shopTile:addEventListener( "touch", createShop)
---------------------------------------------------------------------------------------

return scene
