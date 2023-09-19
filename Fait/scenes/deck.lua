local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require("Scripts.screen")
local userdata = require("Scripts.userdata")
local settings = require("Scripts.settings")
local widget = require( "widget" )
local playerStatusBar = require("Widgets.playerStatusBar")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )


local buttonClose


local function handleButtonEvent( event )
	if event.phase == "ended" then
		userdata.save()
		composer.hideOverlay( "fade", 100 )
	end
	return true
end


local function cardBuy( event )
	if event.phase == "ended" then
		print( "cardBuy", event.target.id )

		-- print( userdata.player.money )

		userdata.save()
		playerStatusBar.update()
	end
	return true
end


local function cardSell( event )
	if event.phase == "ended" then
		print( "cardSell", event.target.id )



		userdata.save()
		playerStatusBar.update()
	end
	return true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}
	-- Code here runs when the scene is first created but has not yet appeared on screen

	if not userdata.player then
		userdata.new()
	end

	local isStore = sceneParams.isStore or false
	print( "deck: isStore", isStore )

	-------------------------------------------------------

	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor(0, 0.5)


	local buttonWidth = 120
	local buttonHeight = 373/1072*buttonWidth

	buttonClose = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = isStore and "Close Store" or "Close Deck",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = handleButtonEvent,
		font = settings.userdata.font,
		fontSize = 18,
	})
	sceneGroup:insert( buttonClose )

	-------------------------------------------------------

	local cardWidth = 136
	local cardHeight = cardWidth*1.5
	local cardPadding = 20
	local cardsPerRow = 5

	local window = display.newRect( sceneGroup, screen.centerX, screen.minY + 80, 800, 600 )
	window:setFillColor( 0.2 )
	window.anchorY = 0

	local xStart = window.x - window.width*0.5 + cardPadding
	local offset

	local card = {}

	-- TODO: Laita tekstit ja kortit scrollView:iin.

	-- Jos ollaan kaupassa, niin laitetaan pelaajan korttien yläpuolelle kaupan kortit.
	if isStore then
		local titleStore = display.newText({
			parent = sceneGroup,
			text = "Store",
			x = screen.centerX,
			y = window.y + 20,
			font = settings.userdata.font,
			fontSize = 40
		})
		titleStore.anchorY = 0

		for i = 1, cardsPerRow do
			-- TODO: generoi kortit card moduulilla.
			local newCard = display.newRect( sceneGroup, xStart + (i-1)*(cardWidth+cardPadding), titleStore.y + titleStore.height, cardWidth, cardHeight )
			newCard.anchorX, newCard.anchorY = 0, 0

			newCard:setFillColor( 0.75 )
			newCard.strokeWidth = 2
			newCard:setStrokeColor( 0.9 )

			newCard.button = widget.newButton({
				left = newCard.x + newCard.width*0.5 - buttonWidth*0.5,
				top = newCard.y + newCard.height - 50,
				width = buttonWidth,
				height = buttonHeight,
				defaultFile = "Resources/Images/generalbutton1.png",
				overFile = "Resources/Images/generalbutton.png",
				label = "BUY",
				labelColor = { default={ 0.9 }, over={ 1 } },
				onEvent = cardBuy,
				font = settings.userdata.font,
				fontSize = 18,
			})
			sceneGroup:insert( newCard.button )

			card[#card+1] = newCard
		end

		offset = card[1].y + card[1].height
	end

	local titleDeck = display.newText({
		parent = sceneGroup,
		text = "Deck",
		x = screen.centerX,
		y = offset and offset + 20 or window.y + 20,
		font = settings.userdata.font,
		fontSize = 40
	})
	titleDeck.anchorY = 0


	-------------------------------------------------------

	local yStart = titleDeck.y + titleDeck.height + cardPadding
	local row, column = 1, 1

	local playerData = userdata.player
	for i = 1, playerData.maxCardsDeck do
		-- TODO: generoi kortit card moduulilla.
		local newCard = display.newRect( sceneGroup, xStart + (column-1)*(cardWidth+cardPadding), yStart + (row-1)*(cardHeight+cardPadding), cardWidth, cardHeight )
		newCard.anchorX, newCard.anchorY = 0, 0

		newCard:setFillColor( 0.5 )
		newCard.strokeWidth = 2
		newCard:setStrokeColor( 0.8 )

		if column == cardsPerRow then
			column = 1
			row = row + 1
		else
			column = column + 1
		end

		if isStore then
			-- TODO: myyntihinta on 2/3 kortin arvosta.
			newCard.button = widget.newButton({
				left = newCard.x + newCard.width*0.5 - buttonWidth*0.5,
				top = newCard.y + newCard.height - 50,
				width = buttonWidth,
				height = buttonHeight,
				defaultFile = "Resources/Images/generalbutton1.png",
				overFile = "Resources/Images/generalbutton.png",
				label = "SELL",
				labelColor = { default={ 0.9 }, over={ 1 } },
				onEvent = cardSell,
				font = settings.userdata.font,
				fontSize = 18,
			})
			sceneGroup:insert( newCard.button )
		end

		card[#card+1] = newCard
	end

	-------------------------------------------------------

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