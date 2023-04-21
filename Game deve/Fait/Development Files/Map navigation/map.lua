--Mietteet:
--1. Pitäisikö menu aueta myös event ja kauppa skeneissä?

--VIAT: PELAAJA VOI BUGATA MENUN AUKI KAUPASSA

local composer = require( "composer" )
local scene = composer.newScene()
local sceneName = "Map"


local menu = require("menu")
local shop = require("shop")
local event = require("event")
local options = require("options")

sceneLayer = "map"


function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        print(sceneName .. " is on the screen")

        -- function enterMap()
        local groupGame = display.newGroup()
        local groupUI = display.newGroup()

        local x, y = display.contentCenterX, display.contentCenterY

        local backGround = display.newImageRect( groupGame, "Images/map.png", 480, 320  )
            backGround.x, backGround.y = x, y

        local menuT = display.newText( groupUI, "Menu", x-200, y-140, native.systemFont, 20 )
            menuT:setFillColor(0,0,1)
            menuT:addEventListener( "touch", function( event )
                if event.phase == "ended" then openMenu() end end )

        -- Tämä funktio vie pelaajan taistelu sceneen generoi viholliset jotka ovat pelaajaa vastassa
        local function openBattle( event )
            if event.phase == "ended" then
                display.remove( groupGame )
                display.remove( groupUI )
                composer.gotoScene( "battle", { time=500, effect="crossFade" } )
            end
        end


        local function createTile( name, group, tileX, tileY,  font, size )
            local newTile = display.newText( name, x, y, font, size )
                newTile:setFillColor(0,0,0)
                newTile.x = tileX
                newTile.y = tileY
                newTile.name = name
                newTile.font = font
                newTile.size = size
                newTile.group = group:insert( newTile )

            return newTile
        end

        local shopTile = createTile( "Shop", groupGame, 120, 220, native.systemFont, 16 )
            shopTile:addEventListener( "touch", openShop )

        local eventTile = createTile( "Event", groupGame, 180, 210, native.systemFont, 16 )
            eventTile:addEventListener( "touch", openEvent )

        local battleTile = createTile( "Battle", groupGame, 240, 190, native.systemFont, 16 )
            battleTile:addEventListener( "touch", openBattle)

        -- timer.performWithDelay(200, function()print(sceneLayer)end, 100000  )


    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        print(sceneName .. " is removed" )
        -- Code here runs when the scene is on screen (but is about to go off screen)
        composer.removeScene( "mapscene" )

    elseif ( phase == "did" ) then


    end
end

--  destroy()
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


---------------------------------------------------------------------------------------

return scene
