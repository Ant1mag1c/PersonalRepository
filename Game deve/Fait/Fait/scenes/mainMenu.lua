display.setStatusBar( display.HiddenStatusBar )

local composer = require("composer")
local scene = composer.newScene()

local screen = require("Scripts.screen")

local disableButtons = false

local function onButtonEvent(event)
    if not disableButtons then
        if event.phase == "began" then
            local target = event.target
            print(target.id)
            disableButtons = true

            if target.id == "quit" then
                native.requestExit()

            else
                if target.id == "options" or target.id == "logBook" then
                    composer.showOverlay("scenes." .. target.id, {
                        isModal = true,
                        effect = "fade",
                        time = 250
                    })
                    disableButtons = false
                else
                    composer.gotoScene("scenes." .. target.id ,{
                        time = 250,
                        effect = "fade"
                    })
                end
            end

        end
    end
    return true
end


function scene:create( event )
    local sceneGroup = self.view

	local background = display.newImage(sceneGroup, "Resources/Images/bgSketch3333.jpg")
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )

    local title = display.newText(sceneGroup,"Roso Games", display.contentCenterX, 16, native.systemFontBold, 28)

    local buttonWidth = 150
    local buttonLenght = 100
    local buttonPadding = 10

    local buttonData = {
        { text="New Game", id="newGame", x=190, y=140, },
        { text="Load Game", id="loadGame", x=190, y=210, },
        { text="Log book", id="logbook", x=190, y=280, },
        { text="Options", id="options", x=190, y=350 },
        { text="Credits", id="credits", x=190, y=420},
        { text="Quit", id="quit", x=190, y=490,}
    }

	local buttonScale = 0.25
	local buttonWidth = 932 * buttonScale
	local buttonHeight = 347 * buttonScale

    for i = 1, #buttonData do
        local button = display.newImageRect(sceneGroup, "Resources/Images/buttonMenu.png", buttonWidth, buttonHeight )
		button.x, button.y = buttonData[i].x, buttonData[i].y
		button.id = buttonData[i].id

        button:addEventListener("touch", onButtonEvent)
        local text = display.newText(sceneGroup, buttonData[i].text , button.x, button.y, native.systemFontBold, 20)
    end

end



function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
		-- Poista edellinen scene aina muistista.
		local previousScene = composer.getSceneName( "previous" )
		if previousScene then
			composer.removeScene( previousScene )
		end

    elseif ( phase == "did" ) then
		disableButtons = false

    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
    end
end


function scene:destroy( event )

    local sceneGroup = self.view
end


scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)
scene:addEventListener("destroy", scene)

return scene