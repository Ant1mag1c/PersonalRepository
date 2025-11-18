local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local widget = require( "widget" )
local shadowText = require( "Scripts.shadowText" )
local loadsave = require( "Scripts.loadsave" )

local buttonLevel = {}
local buttonBack

local levelData = require( "Data.levelData" )

-- Function to handle button events
local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then
		local id = event.target.id
		-- print( id )

		if id == "back" then
			composer.gotoScene( "Scenes.menu", { effect = "fade", time = 500 } )

		else
			-- Jos pelaaja ei painanut "back" nappia, niin event.target.id sisältää kentän tunnuksen.
			-- Siirrytään game sceneen ja välitetään sille kentän tunnus.
			composer.gotoScene( "Scenes.game", { effect = "fade", time = 500,
				params = {
					level = id
				}
			} )

		end

	end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImage( sceneGroup, "Images/menuBG.png", display.contentCenterX, display.contentCenterY )

	local widthScale = display.actualContentWidth / background.width
	local heightScale = display.actualContentHeight / background.height

	local scale = math.max( widthScale, heightScale )
	background:scale( scale, scale )

	shadowText.new({
		parent = sceneGroup,
		text = "Level Select",
		x = display.contentCenterX,
		y = display.screenOriginY + 42,
		font = "Fonts/munro.ttf",
		fontSize = 72,
	})

	local options =
	{
		-- The params below are required
		width = 18,
		height = 18,
		numFrames = 64,
	}
	local imageSheet = graphics.newImageSheet( "Maps/Tiles/tilemap.png", options )

	local coinIcon = display.newImageRect( sceneGroup, imageSheet, 47, 24, 24 )
	coinIcon.x, coinIcon.y = display.contentCenterX - 52, display.screenOriginY + 100
	coinIcon.xScale, coinIcon.yScale = 2, 2

	shadowText.new({
		parent = sceneGroup,
		text = "x " .. loadsave.userdata.coinsCollected,
		x = coinIcon.x + coinIcon.width*0.5 * coinIcon.xScale + 10,
		y = coinIcon.y,
		anchorX = 0,
		font = "Fonts/munro.ttf",
		fontSize = 40,
	})

	buttonBack = widget.newButton(
		{
			x = display.contentCenterX,
			-- y = buttonOptions.y + buttonOptions.height + 20,
			y = 600,
			id = "back",
			label = "Back",
			labelAlign = "center",
			labelColor = { default={ 0.9 }, over={ 1 } },
			onEvent = handleButtonEvent,
			fontSize = 48,
			font = "Fonts/munro.ttf",
			shape = "rect",
			fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
			isEnabled = false,
		}
	)
	sceneGroup:insert( buttonBack )

	-- Luetaan levelData.lua tiedoston taulukosta tiedot ja luodaan sen mukaan napit.
	for i = 1, #levelData do

		buttonLevel[i] = widget.newButton(
			{
				x = levelData[i].x,
				y = levelData[i].y,
				id = levelData[i].filename,
				label = levelData[i].label,
				labelAlign = "center",
				labelColor = { default={ 0.9 }, over={ 1 } },
				onEvent = handleButtonEvent,
				fontSize = 48,
				font = "Fonts/munro.ttf",
				shape = "rect",
				fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
				width = 240,
				isEnabled = false,
			}
		)
		sceneGroup:insert( buttonLevel[i] )

	end

end


-- show()
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		buttonBack:setEnabled( true )
		for i = 1, #buttonLevel do
			buttonLevel[i]:setEnabled( true )
		end

    end
end


-- hide()
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
		buttonBack:setEnabled( false )
		for i = 1, #buttonLevel do
			buttonLevel[i]:setEnabled( false )
		end

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