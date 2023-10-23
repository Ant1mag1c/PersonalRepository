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
local cardScript = require("Scripts.Card")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )

local sceneParams
local buttonClose
local scrollView

local card = {}
local slot = {}

-- -----------------------------------------------------------------------------------

-- Visuaalisia asetuksia:
local buttonWidth = 120
local buttonHeight = 373/1072*buttonWidth
local cardWidth = 140
local cardHeight = cardWidth*1.65
local cardPadding = 20
local cardsPerRow = 5

-- Kauppa asetuksia:
local sellPriceRatio = 0.15

-- -----------------------------------------------------------------------------------

local function closeScene( event )
	if event.phase == "ended" then
		userdata.save()
		composer.hideOverlay( "fade", 100 )
	end
	return true
end


local function cardBuy( target )
	print( "buy:", target.id )
	local _card = target._view._attachedCard
	local price = math.ceil( _card.data.price )

	if userdata.player.money < price then
		print( "not enough money" )
		return
	end

	if #userdata.player.cards == userdata.player.maxCardsDeck then
		print( "no space left" )
		return
	end

	userdata.player.money = userdata.player.money - price
	userdata.player.cards[#userdata.player.cards + 1] = target.id

	local newSlot
	for i = 1, #slot do
		if not slot[i].gotCard then
			newSlot = slot[i]
			slot[i].gotCard = true
			break
		end
	end

	_card.x, _card.y = newSlot.x, newSlot.y
	_card:toFront()

	-- Poistetaan vanha nappi pois käytöstä.
	target:setEnabled( false )
	target:setLabel( "BOUGHT" )
	target.alpha = 0.5

	-- Jos kortti siirtyy myydyn kortin tekemään tyhjään tilaan,
	-- niin poista siinä slotissa oleva vanha "SOLD" nappi.
	display.remove( newSlot.button )

	-- Luodaan uusi nappi vain visuaalista ilmettä varten.
	local fakeButton = widget.newButton({
		left = _card.x - buttonWidth*0.5,
		top = _card.y + _card.height*0.5 + buttonHeight*0.5 - 10,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = "NEW",
		labelColor = { default={ 0.9 }, over={ 1 } },
		font = settings.userdata.font,
		fontSize = 16,
	})
	scrollView:insert( fakeButton )
	fakeButton:setEnabled( false )
	fakeButton.alpha = 0.5

	userdata.save()
	playerStatusBar.update()
end


local function cardSell( target )
	print( "sell:", target.id )
	local _card = target._view._attachedCard
	local price = math.ceil( _card.data.price*sellPriceRatio )

	if #userdata.player.cards == 1 then
		print( "can't sell last card" )
		return
	end

	-- Anna pelaajalle rahat ja poista kortti hänen kokoelmastaan.
	userdata.player.money = userdata.player.money + price
	for i = 1, #userdata.player.cards do
		if userdata.player.cards[i] == target.id then
			table.remove( userdata.player.cards, i )
			break
		end
	end

	display.remove( _card )
	_card.slot.gotCard = false

	-- Poistetaan vanha nappi pois käytöstä.
	target:setEnabled( false )
	target:setLabel( "SOLD" )
	target.alpha = 0.5

	userdata.save()
	playerStatusBar.update()
end


-- Hallitaan scrollView:n sisällä olevien buttonien tapahtumia.
local function onButtonEvent( event )
	local phase = event.phase

	-- Jos pelaaja vetää ylös tai alas riittävästi, niin hän todennäköisesti haluaa scrollata.
	if phase == "moved" then
		local dy = math.abs( ( event.y - event.yStart ) )
		if ( dy > 10 ) then
			scrollView:takeFocus( event )
		end
	elseif phase == "ended" then
		-- Nappien nimissä löytyy hinnat, niin katsotaan vain onko kyseessä osto vai myynti.
		local label = event.target:getLabel():sub(1,3)
		if label == "BUY" then
			cardBuy( event.target )
		else
			cardSell( event.target )
		end
	end
	return true
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	sceneParams = event.params or {}

	-------------------------------------------------------

	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor(0, 0.5)

	-------------------------------------------------------

	local isStore = sceneParams.isStore or false
	local isPharma = sceneParams.isPharma or false
	local isTavern = sceneParams.isTavern or false
	local eventCard = sceneParams.eventCard or {}
	local label

	if eventCard.title then
		for i = 1, #eventCard do
			print( "eventCardCount", i )
		end
		print( "title:", eventCard.title)
	else
		print( "no title for eventCard" )
	end

	-- table.print(eventCard)

	if isStore then
		label = "Close Store"
	elseif isPharma then
		label = "Close Pharma"
	elseif isTavern then
		label = "Close Tavern"
	else
		label = "Close Deck"
	end

	buttonClose = widget.newButton({
		left = screen.maxX - buttonWidth,
		top = screen.minY,
		width = buttonWidth,
		height = buttonHeight,
		defaultFile = "Resources/Images/generalbutton1.png",
		overFile = "Resources/Images/generalbutton.png",
		label = label ,
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = closeScene,
		font = settings.userdata.font,
		fontSize = 18,
	})
	sceneGroup:insert( buttonClose )

	-------------------------------------------------------

	-- Jos devaaja hyppää suoraan tähän sceneen niin userdataa ei ole vielä luotu.
	if not userdata.player then
		userdata.new()

		playerStatusBar.create( sceneGroup, buttonClose )
	end

	local currentMap = userdata.player.currentMap or sceneParams.currentMap or 1
	-- print( "deck: isStore", isStore )

	-------------------------------------------------------

	-- TODO: korjaa hienommalla grafiikalla.
	local window = display.newRect( sceneGroup, screen.centerX, 60, 800, 550 )
	window:setFillColor( 0.2 )
	window.anchorY = 0

	scrollView = widget.newScrollView
	{
		top = 60,
		left = 80,
		width = 800,
		height = 550,
		-- backgroundColor = { 0.2, 0.2 },
		hideBackground = true,
		-- scrollWidth = 600,
		-- scrollHeight = 800,
		horizontalScrollDisabled = true
	}
	sceneGroup:insert( scrollView )


	local xStart = window.x - window.width*0.5
	local offset

	-- Jos ollaan kaupassa, niin laitetaan pelaajan korttien yläpuolelle kaupan kortit.
	if isStore then
		-- Luo numeroitu lista kaikista pelin korteista.
		local cardList = {}
		for cardName, v in pairs( cardData ) do
			cardList[#cardList+1] = v
			cardList[#cardList].name = cardName
		end

		local titleStore = display.newText({
			text = "Store",
			x = 400,
			y = 10,
			font = settings.userdata.font,
			fontSize = 40
		})
		scrollView:insert( titleStore )
		titleStore.anchorY = 0

		for i = 1, cardsPerRow do
			-- Valitse satunnainen kortti, joka on saatavilla nykyisellä kartalla.
			table.shuffle( cardList )
			local cardForSale = eventCard[i] or nil
			if not cardForSale then
				for cardIndex = 1, #cardList do
					if cardList[cardIndex].firstMap <= currentMap and cardList[cardIndex].lastMap >= currentMap then
						cardForSale = cardList[cardIndex].name
						break
					end
				end
			end

			local cardSlot = display.newRect( xStart + (i-1)*(cardWidth+cardPadding), titleStore.y + titleStore.height + cardHeight*0.5 + 20, cardWidth, cardHeight )
			cardSlot:setFillColor( 0.5 )
			cardSlot.strokeWidth = 2
			cardSlot:setStrokeColor( 0.8 )
			scrollView:insert( cardSlot )

			local newCard = cardScript.newCard( cardForSale, nil, {
				x = xStart + (i-1)*(cardWidth+cardPadding),
				y = titleStore.y + titleStore.height + cardHeight*0.5 + 20,
				noShuffle = true,
				cardRevealed = true,
			})
			scrollView:insert( newCard )
			cardSlot.gotCard = true

			newCard.button = widget.newButton({
				left = newCard.x - buttonWidth*0.5,
				top = newCard.y + newCard.height*0.5 + buttonHeight*0.5 - 10,
				width = buttonWidth,
				height = buttonHeight,
				defaultFile = "Resources/Images/generalbutton1.png",
				overFile = "Resources/Images/generalbutton.png",
				label = "BUY "  .. math.ceil(newCard.data.price) .. "G",
				id = randomCard,
				labelColor = { default={ 0.9 }, over={ 1 } },
				onEvent = onButtonEvent,
				font = settings.userdata.font,
				fontSize = 16,
			})
			scrollView:insert( newCard.button )
			-- Hack: buttonin kautta pääsee käsiksi korttiin.
			newCard.button._view._attachedCard = newCard
			newCard.slot = cardSlot

			card[#card+1] = newCard
			slot[#slot+1] = cardSlot
		end

		offset = card[1].button.contentBounds.yMax
	end

	local titleDeck = display.newText({
		text = "Deck",
		x = 400,
		y = offset and offset + 20 or 10,
		font = settings.userdata.font,
		fontSize = 40
	})
	scrollView:insert( titleDeck )
	titleDeck.anchorY = 0

	-------------------------------------------------------

	local yStart = titleDeck.y + titleDeck.height + cardHeight*0.5 + cardPadding
	local row, column = 1, 1
	local yMax

	local playerData = userdata.player
	for i = 1, playerData.maxCardsDeck do
		local newCard

		-- Jokaisella kortilla on paikka, "slot", mihin se asetetaan.
		local cardSlot = display.newRect( xStart + (column-1)*(cardWidth+cardPadding), yStart + (row-1)*(cardHeight+cardPadding + buttonHeight + 10), cardWidth, cardHeight )
		cardSlot:setFillColor( 0.5 )
		cardSlot.strokeWidth = 2
		cardSlot:setStrokeColor( 0.8 )
		scrollView:insert( cardSlot )

		yMax = cardSlot.y + cardSlot.height

		-- Pelaajan kortit.
		if i <= #userdata.player.cards then
			newCard = cardScript.newCard( userdata.player.cards[i], nil, {
				x = xStart + (column-1)*(cardWidth+cardPadding),
				y = yStart + (row-1)*(cardHeight+cardPadding + buttonHeight + 10),
				noShuffle = true,
				cardRevealed = true,
			})
			scrollView:insert( newCard )
			cardSlot.gotCard = true
		end

		if column == cardsPerRow then
			column = 1
			row = row + 1
		else
			column = column + 1
		end

		if isStore and newCard then
			newCard.button = widget.newButton({
				left = newCard.x - buttonWidth*0.5,
				top = newCard.y + newCard.height*0.5 + buttonHeight*0.5 - 10,
				width = buttonWidth,
				height = buttonHeight,
				defaultFile = "Resources/Images/generalbutton1.png",
				overFile = "Resources/Images/generalbutton.png",
				label = "SELL " .. math.ceil(newCard.data.price*sellPriceRatio) .. "G",
				labelColor = { default={ 0.9 }, over={ 1 } },
				id = userdata.player.cards[i],
				onEvent = onButtonEvent,
				font = settings.userdata.font,
				fontSize = 16,
			})
			scrollView:insert( newCard.button )
			-- Hack: buttonin kautta pääsee käsiksi korttiin.
			newCard.button._view._attachedCard = newCard
			newCard.slot = cardSlot
			cardSlot.button = newCard.button
		end

		card[#card+1] = newCard
		slot[#slot+1] = cardSlot
	end

	-- Lisätään scrollView:n loppuun "tyhjä tila", jotta viimeinen rivi näkyy.
	local bottomPadding = display.newRect( 400, yMax - 40, 800, 40 )
	bottomPadding.anchorY = 0
	bottomPadding.isVisible = false
	scrollView:insert( bottomPadding )

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