local composer = require( "composer" )

local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local widget = require( "widget" )
local screen = require( "scripts.screen" )
local layer
local scrollSpeed = 15000
local scrollView
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local id = event.target.id
        -- print( id )

        if id == "back" then
            composer.gotoScene( "scenes.mainMenu", { effect = "fade", time = 500 } )
        end
    end
end

-- create()
function scene:create( event )
    local sceneGroup = self.view

    local background = display.newImage( sceneGroup, "assets/images/uifolder/taustakuva.png", screen.centerX, screen.centerY )
    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end


    local myText = display.newText( sceneGroup, "Credits", screen.centerX, screen.centerY*0.1, native.systemFont, 32 )
    myText:setFillColor( 1, 0, 0 )

    local buttonList = {
        button1 = {
            id = "back",
            label = "Back",
            x = screen.width*0.05,
            y = screen.height-20,
            fontSize = 32,
            onEvent = handleButtonEvent
        }
    }

    -- Luodaan in pairs loopilla kaikille buttonList taulussa oleville painikkeille
    -- oma display objekti ja lisätään niille toiminnallisuus
    for key, value in pairs(buttonList) do
        local newButton = widget.newButton(
            {
                id = value.id,
                label = value.label,
                fontSize = value.fontSize,
                onEvent = value.onEvent
            }
        )

        newButton.y = value.y
        newButton.x = value.x

        sceneGroup:insert(newButton)
    end

    -- Luodaan scrollattava tekstikenttä, joka lähtee automaattisesti rullaamaan alaspäin.
	local scrollWidth = 400
	scrollView = widget.newScrollView(
		{
			top = 100,
			-- left = (screen.width - scrollWidth)*0.5,
			left = screen.centerX - scrollWidth*0.5,
			width = scrollWidth,
			height = 500,
			scrollWidth = 3000,
			scrollHeight = 800,
            bottomPadding = 100,
			backgroundColor = { 0.3, 0.8 },
            horizontalScrollDisabled = true,
            hideScrollBar = true
		}
	)
	sceneGroup:insert( scrollView )


    -- Tekijöiden nimet ja roolit.
    local credits = {
        { "" },
        { "ROSO GAMES 2023", 1 },
        { "" },
        { "" },

        { "PROGRAMMING", 2 },
        { "PERSON1", 3 },
        { "PERSON2", 3 },
        { "" },

        { "MINOR PROGRAMMING", 2 },
        { "PERSON1", 3 },
        { "PERSON2", 3 },
        { "" },

        { "DESIGN", 2 },
        { "PERSON1", 3 },
        { "PERSON2", 3 },
        { "" },

        { "ART", 2 },
        { "PERSON1", 3 },
        { "PERSON2", 3 },
        { "" },

        { "AUDIO", 2 },
        { "PERSON1", 3 },
        { "PERSON2", 3 },
        { "" },

        { "ROSO GAMES LEAD", 2 },
        { "Eetu Rantanen" },
        { "" },
        { "" },
        { "" },
    }

    -- Lisätään tekstit yläpuolelta scrollattavaan tekstikenttään.
    local text = {}
    local maxY = 0

    for i = 1, #credits do

        local fontSize = 30
        local padding = 2

        local style = credits[i][2]
        if style then
            if style == 1 then
                fontSize = 32
            elseif style == 2 then
                fontSize = 28
            elseif style == 3 then
                fontSize = 24
            end
        end

        text[i] = display.newText({
            parent = scrollView,
            text = credits[i][1],
            width = scrollWidth,
            align = "center",
            font = native.systemFont,
            fontSize = fontSize,
            x = scrollWidth*0.5,
            y = (text[i-1] and text[i-1].y + text[i-1].height + padding or 0)
        })

        text[i].anchorY = 0

        if style and style ~= 3 then
            text[i]:setFillColor( 80/255, 218/255, 169/255 )
        end

        scrollView:insert(text[i])
        maxY = text[i].y + text[i].height*0.5 - 20
    end

end


-- show()
function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        scrollView:scrollTo( "bottom", { time=scrollSpeed } )
    end
end


-- hide()
function scene:hide( event )

    local phase = event.phase

    if ( phase == "will" ) then

        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )


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