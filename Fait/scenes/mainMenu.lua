local composer = require("composer")
local scene = composer.newScene()

local userdata = require("Scripts.userdata")
local settings = require("Scripts.settings")
local screen = require("Scripts.screen")
local widget = require("widget")

local button = {}
local disableButtons = false

local function onButtonEvent(event)
    if not disableButtons then
        if event.phase == "ended" then
            local target = event.target
            -- print(target.id)
            disableButtons = true

            if target.id == "quit" then
                native.requestExit()
				disableButtons = false

            else
                if target.id == "options" or target.id == "logBook" then
                    composer.showOverlay("scenes." .. target.id, {
                        isModal = true,
                        effect = "fade",
                        time = 250
                    })
                    disableButtons = false

				elseif target.id == "continue" then
                    composer.gotoScene("scenes.map" ,{
                        time = 250,
                        effect = "fade"
                    })

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

	local versionNumber = (system.getInfo( "environment" ) == "simulator" and "SIM" or system.getInfo( "appVersionString" )  .. " (pre-alpha)")
	local versionLabel = display.newText(sceneGroup, "Version: " .. versionNumber, screen.maxX - 6, screen.maxY - 6, settings.userdata.font, 22 )
	versionLabel.anchorX, versionLabel.anchorY = 1, 1
	versionLabel:setFillColor( 0 )

	local logoWidth = 400
	local logoHeight = 621 / 1904 * logoWidth
    local logo = display.newImageRect( sceneGroup, "Resources/Images/sisuvalalogo3.png", logoWidth, logoHeight )
	logo.x, logo.y = display.contentCenterX, screen.minY + logoHeight/2 + 10

    local buttonData = {
        { text="New Game", id="newGame", x=190, y=140, },
        -- { text="Load Game", id="loadGame", x=190, y=210, },
        { text="Continue", id="continue", x=190, y=210, },
		-- TODO: log book poistettu toistaiseksi.
        -- { text="Log book", id="logbook", x=190, y=280, },
        { text="Options", id="options", x=190, y=350 },
        { text="Credits", id="credits", x=190, y=420},
        { text="Quit", id="quit", x=190, y=490,}
    }


	local buttonWidth = 220
	local buttonHeight = 373/1072*buttonWidth

	local x = 190
	local yPrev = 140

    for i = 1, #buttonData do
		button[i] = widget.newButton({
			width = buttonWidth,
			height = buttonHeight,
			defaultFile = "Resources/Images/generalbutton1.png",
			overFile = "Resources/Images/generalbutton.png",
			id = buttonData[i].id,
			label = buttonData[i].text,
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = onButtonEvent,
			font = settings.userdata.font,
			fontSize = 22,
		})
		button[i].x, button[i].y = x, yPrev
		sceneGroup:insert( button[i] )

		yPrev = yPrev + button[i].height + 10
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

		-- Jos vanhaa savefilea ei löydy, disabloi continue nappi.
		local savefileFound = userdata.load()
		if not savefileFound then
			button[2]:setEnabled(false)
			button[2].alpha = 0.7
		else
			button[2]:setEnabled(true)
			button[2].alpha = 1
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