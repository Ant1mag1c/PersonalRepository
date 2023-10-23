local card = {}

local userdata = require("Scripts.userdata")
local settings = require("Scripts.settings")
local screen = require("Scripts.screen")

local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )

-----------------------------------------------------------------------------------------

-- Kortti voi olla joko pakassa, pelaajan kädessä tai pelattujen korttien pinossa.
card.deck = {}
card.hand = {}
card.discard = {}
card.canPlay = true
local activeCard
local turnListener
local cardEffectListener

-----------------------------------------------------------------------------------------

local cardFlipTime = 250

-- TODO: kortti grafiikoiden koko on valtava ja niitä tulee pienentää. Osassa grafiikoista on
-- myös 90-95% pelkkää tyhjää tilaa, jotka syövät turhaan muistia.

-- Kortin leveys ja sen tekstien reunojen turva-alueet:
local cardWidth = 140
local imageWidth = 100
local imageHeight = 80
local titlePadding = 20
local descriptionPaddingHorizontal = 8

local cardPaddingInHand = 10
local cardTimePerPixel = 1

local cardGraphicWidth, cardGraphicHeight = 900, 1500
-- Kortin skaala lasketaan automaattisesti annetun leveyden ja kortti grafiikan suhteen avulla.
local cardScale = cardWidth / cardGraphicWidth
local cardHeight = cardGraphicHeight*cardScale

-- Korttien sijainnit ruudulla ym. sijainnin/asetelman visuaalinen kustomointi:
local cardLocation = {
	deck = {
		x = screen.minX + cardWidth - 60,
		y = screen.maxY - cardHeight + 100,
		scale = 0.9,
		rotationVar = 1,
	},
	hand = {
		x = screen.centerX,
		y = screen.maxY - cardHeight + 110,
		scale = 1,
		rotationChange = 2,
	},
	discard = {
		x = screen.maxX - cardWidth + 65,
		y = screen.maxY - cardHeight + 115,
		scale = 0.9,
		rotationVar = 5,
	},
}

-----------------------------------------------------------------------------------------

local function scaleToFit( object, widthToFit )
	if object.width > widthToFit then
		local scale = math.min( widthToFit / object.width )
		object:scale( scale, scale )
	end
end

--when a card is clicked, it becomes slightly bigger
local function cardToggle(target, isSelected)
    if isSelected then
        target.xScale, target.yScale = 1.1, 1.1
    else
        target.xScale, target.yScale = 1.0, 1.0
    end
end

local function selectCard(event)
	-- Jos kortti ei ole pelaajan kädessä, niin sitä ei voi valita.
	local inHand = event.target.inHand

    if card.canPlay and inHand then
        local target = event.target
        local phase = event.phase

        --when a card is touched, select it
        if phase == "began" then
            display.getCurrentStage():setFocus( target )
            target.isTouched = not target.isTouched

            --if card has already been selected, deselect it
            if target == activeCard then
                cardToggle(target, false)
                activeCard = nil

            else
                local didPlayCard = activeCard

                if activeCard then
                    didPlayCard = card.playCard(event)
                    if not didPlayCard then
                        cardToggle(activeCard, false)
                    end
                end

                if not didPlayCard then
                    cardToggle(target, true)
                    activeCard = target
                end
            end

        elseif phase == "ended" then
            display.getCurrentStage():setFocus( nil);
        end
    end

	-- Kosketuksia ei tarvitse rekisteröidä, jos kortilla ei voi tehdä mitään.
    return inHand
end


function card.update( target )
	-- TODO: korttiin tarvitsee luoda update funktion, joka päivittää kortin tiedot ja luo etupuolen uudestaan.

end


function card.newCard( cardName, parent, params )
    local data = cardData[cardName]
	if not data then
		print( "Korttia ei ole olemassa: ", cardName )
		return
	end

	-- Jos kortista puuttuu jokin kriittinen elementti, esim. kuva tai kuvaus, niin täytetään ne ettei peli kaadu.
	data.description = data.description or "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor."

	-- Debug print:
	---------------
	-- print("")
	-- for k, v in pairs( data ) do
	-- 	print( k, v )
	-- end
	---------------

	-- Luo kortti useista palasista, mutta tee niistä lopulta yksi display object capturen avulla,
	-- jotta kortteja voi manipuloida rect.path:in kautta.
    local cardBase = display.newGroup()
    cardBase.x, cardBase.y = screen.minX - cardWidth*2, screen.maxY + cardHeight *2 -- Tee kortit piilossa, ruudun ulkopuolella.

    local bg = display.newImageRect( cardBase, "Resources/Images/Cards/cardBack.png", cardWidth, cardHeight )
    local divider = display.newImageRect(cardBase,"Resources/Images/Cards/divider.png", cardWidth, cardHeight )
	local alignment

	if data.alignment == "fields" then
		alignment = display.newImageRect(cardBase,"Resources/Images/Cards/kapalikko.png", cardWidth, cardHeight)
	else
		alignment = display.newImageRect(cardBase,"Resources/Images/Cards/ukonkirves.png", cardWidth, cardHeight)
	end
	alignment:scale( 0.6, 0.6 )
	alignment.y = alignment.y - 46

	local image = display.newImageRect(cardBase, "Resources/Images/Cards/" .. data.image, imageWidth, imageHeight )

	-- Jos kuvaa ei ole, niin käytä tekstiä väliaikaisena korvikkeena ettei peli kaadu.
	if not image then
		image = display.newText({
			parent = cardBase,
			text = data.image,
			x = 0,
			y = -cardHeight*0.1,
			font = settings.userdata.font,
			fontSize = 120*cardScale,
			align = "center"
		})

		scaleToFit( image, cardWidth - titlePadding*2 )
	end


    local energy = display.newText({
		parent = cardBase,
		text = data.energy,
		x = bg.width*0.5 - 12,
		y = -bg.height*0.5 + 4,
		font = settings.userdata.font,
		fontSize = 25
	})
	energy.anchorX, energy.anchorY = 1, 0

	local title = display.newText({
		parent = cardBase,
		text = cardName,
		x = 0,
		y = 12,
		font = settings.userdata.font,
		fontSize = 20
	})
	scaleToFit( title, cardWidth - titlePadding )

	local description = display.newText({
		parent = cardBase,
		text = data.description,
		x = 0,
		y = 40,
		align = "center",
		width = cardWidth - descriptionPaddingHorizontal*2,
		height = 68,
		font = settings.userdata.font,
		fontSize = 10
	})
	description.anchorY = 0

	-- Tee kortin etupuolesta yksi display object ja poista pohja:
	local cardNew = display.newGroup()
	if parent then
		parent:insert( cardNew )
	end

	if params.isGameDeck then
		-- Laita uusi kortti aina vähän aiempaa ylemmäs pakkaan, niin kortit näyttävät olevan pinossa.
		cardNew.x, cardNew.y = cardLocation.deck.x, cardLocation.deck.y - (#card.deck*2)
		cardNew.xScale, cardNew.yScale = cardLocation.deck.scale, cardLocation.deck.scale
		cardNew.rotation = math.random(-cardLocation.deck.rotationVar, cardLocation.deck.rotationVar)
	else
		cardNew.x, cardNew.y = params.x or cardNew.x, params.y or cardNew.y
		cardNew.xScale, cardNew.yScale = params.xScale or cardNew.xScale, params.yScale or cardNew.yScale
		cardNew.rotation = params.rotation or cardNew.rotation
	end
	cardNew.xStart, cardNew.yStart = cardNew.x, cardNew.y
	cardNew.startScale = cardNew.xScale

	cardNew.front = display.capture( cardBase, { captureOffscreenArea=true } )
	cardNew:insert( cardNew.front )
	display.remove( cardBase )

	-- Jos ollaan pelissä, niin käännä kortin etupuoli odottamaan piiloon. Muutoin kortin takaosaa ei edes tarvita.
	if not params.cardRevealed then
		local cardHalfWidth = cardNew.front.width * 0.5
		transition.to( cardNew.front.path, { time=0, x1=cardHalfWidth, x2=cardHalfWidth, x3=-cardHalfWidth, x4=-cardHalfWidth })

		-- Kortin tausta näkyy päällimmäisenä alkuun.
		cardNew.back = display.newImageRect( cardNew, "Resources/Images/Cards/cardBack.png", cardWidth, cardHeight )
	end

	-- Kopioi kaikki kortin tiedot ylös:
    cardNew.type = "card"
	cardNew.data = {}
	cardNew.data.name = cardName
	for k, v in pairs( data ) do
		cardNew.data[k] = v
	end

	if params.isGameDeck then
		cardNew:addEventListener("touch", selectCard)
		card.deck[#card.deck+1] = cardNew
	end

    return cardNew
end

-- Sekoitetaan kortit ja luodaan uusi pakka.
function card.newDeck( parent, _turnListener, _cardEffectListener, params )
	-- Vapaaehtoiset parametrit, jos pakka luodaankin battle scenen ulkopuolella (ei pelipakka).
	params = params or {}
	-- Vuoro voidaan lopettaa automaattisesti, jos pelaajan kädessä olevat kortit loppuvat.
	turnListener = _turnListener
	-- Korttien vaikutukset käsitellään battle scenessä.
	cardEffectListener = _cardEffectListener
	-- Laitetaan kortit väliaikaiseen taulukkoon, että ne voidaan sekoittaa ennen kun kortit luodaan.
	-- Näin vältetään että kortit pysyvät samassa järjestyksessä datassa ja ne laitetaan pakkaan
	-- oikeassa järjestyksessä.
	local t = {}
	for i = 1, #userdata.player.cards do
		t[i] = userdata.player.cards[i]
	end

	if not params.noShuffle then
		table.shuffle( t )
	end

	for i = 1, #t do
		card.newCard( t[i], parent, params )
	end
end


function card.flipCard( target, time )
	local cardHalfWidth = target.width * 0.5
	time = time or cardFlipTime

	local toHide, toReveal

	if target.inHand then
		toHide = target.back
		toReveal = target.front
	else
		toHide = target.front
		toReveal = target.back
	end

	-- Kaikki kortit tulevat taas käsiteltäviksi kun kortti on käännetty.
	transition.to( toHide.path, { time=time*0.5, x1=cardHalfWidth, x2=cardHalfWidth, x3=-cardHalfWidth, x4=-cardHalfWidth, onComplete=function()
		transition.to( toReveal.path, { time=time*0.5, x1=0, x2=0, x3=0, x4=0, onComplete=function()

			-- Kortit ovat loppu pelaajan kädestä.
			if #card.hand == 0 then
				-- Pakassa on vielä kortteja, niin siirrytään heti vihollisten vuoroon.
				if #card.deck > 0 then
					if turnListener then
						turnListener( "outOfCards" )
					end
				-- Pakka on tyhjä, joten sekoitetaan discard pile ja luodaan uusi pakka.
				else
					local function onComplete()
						if turnListener then
							turnListener( "outOfCards" )
						end
					end

					table.shuffle( card.discard )
					local lastCard = #card.discard

					for i = 1, #card.discard do
						card.deck[#card.deck+1] = card.discard[i]
						card.discard[i] = nil
						card.deck[#card.deck]:toFront()

						transition.to( card.deck[#card.deck], {
							time=500,
							xScale=cardLocation.deck.scale,
							yScale=cardLocation.deck.scale,
							x=cardLocation.deck.x,
							y=cardLocation.deck.y - (#card.deck*2),
							rotation=math.random(-cardLocation.deck.rotationVar, cardLocation.deck.rotationVar),
							transition=easing.inOutBack,
							onComplete= i == lastCard and onComplete or nil
						})
					end
				end
			end
		end})
	end})
end


function card.moveCards()
	if #card.hand > 0 then
		local thisCard = card.hand[#card.hand]

		-- Siirretään kaikkia pelaajan käsissä olevia kortteja dynaamisesti.
		local realWidth = (thisCard.contentBounds.xMax - thisCard.contentBounds.xMin)/thisCard.xScale
		local xStart = cardLocation.hand.x
		local offset = realWidth + cardPaddingInHand
		if #card.hand > 1 then
			local count = (#card.hand - 1)/2
			xStart = xStart + offset*count
		end

		-- Lopeta vanhat slide transitionit ja aloita uudet käyttäen vakioliikkuminopeutta.
		transition.cancel( "cardSlide" )

		for i = 1, #card.hand do
			local toX = xStart - offset*(i-1)
			local distance = math.sqrt( (card.hand[i].x - toX)^2 + (card.hand[i].y - cardLocation.hand.y)^2 )
			transition.to( card.hand[i], {
				time=distance*cardTimePerPixel,
				tag="cardSlide",
				x=toX,
				y=cardLocation.hand.y,
				xScale=cardLocation.hand.scale,
				yScale=cardLocation.hand.scale,
				rotation=0,
			})
		end
	end
end

-- Nosta uusi kortti pakasta ja laita se pelaajan käteen.
function card.dealCard(event)
	local cardNum = #card.deck

	-- Laitetaan pakan ylin kortti pelaajan käteen.
	card.hand[#card.hand+1] = card.deck[cardNum]
	card.hand[#card.hand].inHand = true
	card.deck[cardNum] = nil

	card.flipCard( card.hand[#card.hand] )
	card.moveCards()
end

function card.discardCard()
    local cardIndex
    for i = 1, #card.hand do
        if activeCard == card.hand[i] then
            cardIndex = i
            break
		end
    end

	-- Poistetaan kortti pelaajan kädestä ja siirretään se pelattujen korttien pinoon.
	table.remove( card.hand, cardIndex )
	table.insert( card.discard, activeCard )
	activeCard.inHand = false
	activeCard:toFront()
	card.moveCards()
	card.flipCard( activeCard )
	transition.to( activeCard, {
		time=500,
		xScale=cardLocation.discard.scale,
		yScale=cardLocation.discard.scale,
		x=cardLocation.discard.x,
		y=cardLocation.discard.y,
		-- 180 astetta, eli flipataan kortit kokonaan ympäri ja sitten vähän randomoidaan lisää (hienomman näköinen).
		rotation=180 + math.random(-cardLocation.discard.rotationVar, cardLocation.discard.rotationVar),
		transition=easing.inOutBack
	})
	activeCard = nil
end

function card.playCard( event )
    if event.phase == "began" and card.canPlay then
        if activeCard then
            card.canPlay = false
            -- print("Target type: " .. event.target.type, "Card target: " .. activeCard.data.target)

            --card is being played a.k.a removed from the screen
            if event.target.type == activeCard.data.target or event.target.type == "enemy" and activeCard.data.target == "enemyAll" then
                -- print("Card played.")
                transition.to(activeCard, {
					time=500,
					rotation=0,
					x=screen.centerX,
					y=activeCard.y - activeCard.height*0.9,
					xScale=1.25,
					yScale=1.25,
					transition=easing.inOutBack,
					onComplete=function()
						if cardEffectListener then
							cardEffectListener( event.target, activeCard )
						end

						card.discardCard()
					end
				})

                return true

            else
                --if a card cannot be played to another card, switch active card
                if event.target.type == "card" then
                    -- print("Switching the active card.")
                    card.canPlay = true
                    return false
                else
                    --if card cannot be played like this, play error sound and animation
                    -- print("Can't play card.")
                    transition.to(activeCard, { time=500, y=activeCard.y+20, xScale=0.85, yScale=0.85, transition=easing.inOutBack, onComplete=function()
                        transition.to(activeCard, { time=500, y=activeCard.y-20, xScale=1.1, yScale=1.1, transition=easing.inOutBack, onComplete=function()
                            card.canPlay = true
                        end })
                    end })

					-- TODO: audio
                    local audio1 = audio.loadSound( "Assets/Audio/error.wav" )
                    local audio1Channel = audio.play( audio1 )
                    return false
                end
            end
        end
    end
    return true
end

return card