local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local currentCharacter = 1


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local title = display.newText(sceneGroup,"Credits", display.contentCenterX, 16, native.systemFontBold, 28)

    local buttonWidth = 150
    local buttonLenght = 100
    local buttonPadding = 10
	local screenWidth = display.contentWidth
	local screenHeight = display.contentHeight

	local buttonWidth = 150
	local buttonLenght = 100
	local buttonPadding = 10

	local function onButtonEvent(event)
		if event.phase == "began" then
			local target = event.target
			if target.id == "back" then
				composer.gotoScene("scenes.mainMenu",{
					time = 250,
					effect = "fade"
				})
			end
		end
		return true
	end

	local button =display.newRect(150, 150, 250, 60)
	local buttonId="back"
		-- x=screenWidth*0.1, y=screenHeight*0.1},
	button:setFillColor(0.2, 0, 0)
	button:addEventListener("touch", onButtonEvent)
	local buttonText = display.newText("Back", 150, 150, native.systemFontBold, 28)
	

	
	

	local widget = require("widget")

	local function scrollListener( event )
	
		local phase = event.phase
		if ( phase == "began" ) then print("Scroll view was touhced")
		elseif ( phase == "moved") then print("Scroll wiew was moved")
		elseif ( phase == "ended") then print ("Scroll view was relased")
		
	
		if (event.limitReached) then
			elseif (event.direction == "up") then print("Reached bottom limit")
			elseif (event.direction == "down") then print("Reached top limit")
			elseif (event.direction == "left") then print("Reached right limit")
			elseif (event.direction == "right") then print("Reached left limit")
			end
		end
	
		return true
	end
	
	local scrollView = widget.newScrollView(
		{
			top = 100,
			left = 400,
			width = 300,
			height = 400,
			scrollWidth = 600,
			scrollHeight = 800,
			listener = scrollListener,
			scrollBarOptions = {
				sheet = scrollBarSheet,
				topFrame = 1,
				middleframe = 2,
				bottomFrame = 3
			}
		}
	)


	-- Code here runs when the scene is first created but has not yet appeared on screen



end
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


--local background = display.newImageRect()
--scrollView:insert( background)


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