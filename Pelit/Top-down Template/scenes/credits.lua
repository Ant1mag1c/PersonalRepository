local composer = require( "composer" )

local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local widget = require( "widget" )
local screen = require( "classes.screen" )
local creditsData = require( "data.credits" )

local scrollView
local buttonBack
local isUserTouching = false
local lastFrameTime = nil
local scrollPixelsPerMs = 0
local maxScrollY = 0
local autoScrollActive = false
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

local function scrollListener( event )
    local phase = event.phase
    if phase == "began" then
        isUserTouching = true
        lastFrameTime = nil
    elseif phase == "ended" then
        isUserTouching = false
        lastFrameTime = nil
        -- Re-enable auto-scroll if user dragged back up from the bottom
        if scrollPixelsPerMs > 0 and not autoScrollActive then
            local _, currentY = scrollView:getContentPosition()
            if currentY > maxScrollY then
                autoScrollActive = true
            end
        end
    end
    return true
end

local function onEnterFrame( event )
    if not autoScrollActive or not scrollView or isUserTouching then
        lastFrameTime = nil
        return
    end

    local currentTime = event.time
    if lastFrameTime == nil then
        lastFrameTime = currentTime
        return
    end

    local dt = currentTime - lastFrameTime
    lastFrameTime = currentTime

    local _, currentY = scrollView:getContentPosition()

    if currentY <= maxScrollY then
        autoScrollActive = false
        return
    end

    local newY = currentY - scrollPixelsPerMs * dt
    if newY < maxScrollY then
        newY = maxScrollY
    end

    scrollView:scrollToPosition({ y = newY, time = 0 })
end

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local id = event.target.id
        -- print( id )

        if id == "back" then
            composer.gotoScene( "scenes.menu", { effect = "fade", time = 500 } )
        end
    end
end


function scene:create( event )
    local sceneGroup = self.view
    local config = creditsData.config

    local background = display.newImage(
		sceneGroup, "assets/images/ui/menu.png",
		screen.centerX,
		screen.centerY
	)
    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end

    local titleCfg = config.title
    local title = display.newText( sceneGroup, titleCfg.text, screen.centerX, screen.minY + titleCfg.yOffset, titleCfg.font, titleCfg.fontSize )
    title.anchorY = 0
    title:setFillColor( titleCfg.color[1], titleCfg.color[2], titleCfg.color[3] )

    local btnCfg = config.backButton
    buttonBack = widget.newButton({
        id = "back",
        label = btnCfg.label,
        labelAlign = btnCfg.labelAlign,
        width = btnCfg.width,
        height = btnCfg.height,
        fontSize = btnCfg.fontSize,
        font = btnCfg.font,
        labelColor = btnCfg.labelColor,
        fillColor = btnCfg.fillColor,
        onEvent = handleButtonEvent,
        shape = btnCfg.shape,
        isEnabled = false,
    })
    buttonBack.x = screen.minX + btnCfg.xOffset
    buttonBack.y = screen.maxY - btnCfg.yOffset
    buttonBack.anchorX,buttonBack.anchorY = 0, 1
    sceneGroup:insert( buttonBack )

    -- Create scrollable text field that automatically starts scrolling
	local svCfg = config.scrollView
	scrollView = widget.newScrollView(
		{
			top = svCfg.top,
			left = screen.centerX - svCfg.width * 0.5,
			width = svCfg.width,
			height = svCfg.height,
			scrollWidth = svCfg.width,
			scrollHeight = svCfg.scrollHeight,
            bottomPadding = svCfg.bottomPadding,
			backgroundColor = svCfg.backgroundColor,
            horizontalScrollDisabled = true,
            hideScrollBar = true,
            listener = scrollListener
		}
	)
	sceneGroup:insert( scrollView )


    -- Create credit entries from data
    local entries = creditsData.entries
    local text = {}

    for i = 1, #entries do
        local entry = entries[i]

        text[i] = display.newText({
            parent = scrollView,
            text = entry.text,
            width = svCfg.width,
            align = "center",
            font = entry.font,
            fontSize = entry.fontSize,
            x = svCfg.width * 0.5,
            y = (text[i-1] and text[i-1].y + text[i-1].height + entry.padding or 0)
        })

        text[i].anchorY = 0
        text[i]:setFillColor( entry.color[1], entry.color[2], entry.color[3] )

        scrollView:insert(text[i])
    end

    -- Calculate scroll metrics for linear scrolling
    local lastText = text[#text]
    if lastText then
        local contentBottom = lastText.y + lastText.height + (svCfg.bottomPadding or 0)
        local scrollableDistance = contentBottom - svCfg.height
        if scrollableDistance > 0 then
            maxScrollY = -scrollableDistance
            scrollPixelsPerMs = scrollableDistance / config.scrollSpeed
        else
            maxScrollY = 0
            scrollPixelsPerMs = 0
        end
    end

end


function scene:show( event )

    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        buttonBack:setEnabled( true )

        -- Start linear auto-scroll if there is content to scroll
        isUserTouching = false
        lastFrameTime = nil
        if scrollPixelsPerMs > 0 then
            local _, currentY = scrollView:getContentPosition()
            if currentY > maxScrollY then
                autoScrollActive = true
                Runtime:addEventListener( "enterFrame", onEnterFrame )
            end
        end
    end
end


function scene:hide( event )

    local phase = event.phase

    if ( phase == "will" ) then
        buttonBack:setEnabled( false )

        -- Stop auto-scroll when leaving the scene
        autoScrollActive = false
        Runtime:removeEventListener( "enterFrame", onEnterFrame )
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------


return scene