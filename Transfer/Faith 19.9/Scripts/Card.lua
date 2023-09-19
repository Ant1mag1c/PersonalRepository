local card = {}
local playerHand = {}
local deck = {}
local activeCard
local canPlayCard = true


local settings = require("Scripts.settings")
local screen = require("Scripts.screen")


local dataHandler = require("Scripts.dataHandler")
local cardData = dataHandler.getData( "cards.tsv" )


--when a card is clicked, it becomes slightly bigger
local function cardToggle(target, isSelected)
    if isSelected then
        target.xScale, target.yScale = 1.1, 1.1
        canPlayCard = true
    else
        target.xScale, target.yScale = 1.0, 1.0
        canPlayCard = true
    end
end

local function selectCard(event)
    if canPlayCard and event.target.inHand == true then
        local target = event.target
        local phase = event.phase
        local stage = display.getCurrentStage()

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
    return true
end

--creating the cards
function card.newCard( cardName, parent )
    local data = cardData[cardName]

	-- print("")
	-- for k, v in pairs( data ) do
	-- 	print( k, v )
	-- end

    local cardWidth = 140

	-- TODO: kortti grafiikoiden koko on valtava ja niitä tulee pienentää. Osassa grafiikoista on
	-- myös 90-95% pelkkää tyhjää tilaa, jotka syövät turhaan muistia.

	-- Kortin skaala lasketaan automaattisesti annetun leveyden ja kortti grafiikan suhteen avulla.
	local cardGraphicWidth, cardGraphicHeight = 900, 1500
	local cardScale = cardWidth / cardGraphicWidth
    local cardHeight = cardGraphicHeight*cardScale

    -- local textWidth = 65
    -- local textHeight = 70

    -- local titleWidth = 100
    -- local titleHeight = 20

    local newCard = display.newGroup()
    newCard.x, newCard.y = screen.minX + cardWidth, screen.maxY - cardHeight
	parent:insert( newCard )

    newCard.background = display.newImageRect( newCard, "Resources/Images/Cards/cardBack.png", cardWidth, cardHeight )
    newCard.divider = display.newImageRect(newCard,"Resources/Images/Cards/divider.png", cardWidth, cardHeight)

	if data.alignment == "fields" then
		newCard.alignment = display.newImageRect(newCard,"Resources/Images/Cards/kapalikko.png", cardWidth, cardHeight)
	else
		newCard.alignment = display.newImageRect(newCard,"Resources/Images/Cards/ukonkirves.png", cardWidth, cardHeight)
	end


	-- TODO: Meillä ei ole vielä kuvia korteille, joten käytetään väliaikaisesti vain tekstiä.
	newCard.image = display.newText({
		parent = newCard,
		text = cardName,
		x = 0,
		y = -cardHeight*0.1,
		font = settings.userdata.font,
		fontSize = 120*cardScale,
		align = "center"
	})

	-- Varmista, että teksti mahtuu kortin sisään.
	if newCard.image.width > cardWidth - 80*cardScale then
		newCard.image.size = 120*cardScale * (cardWidth - 80*cardScale) / newCard.image.width
	end

	-- newCard.image

    -- newCard.image = display.newImageRect(newCard,"Resources/Images/Cards/" .. data.image, 65, 65)
    -- newCard.image.x, newCard.image.y = 0, cardHeight*0.175

    -- newCard.image = display.newImageRect(newCard,"Resources/Images/Cards/" .. data.image, 65, 65)
    -- newCard.image.x, newCard.image.y = 0, -cardHeight*0.175

    -- newCard.frame = display.newImageRect(newCard, "Resources/Images/Cards/" .. data.frame, 78, 78 )
    -- newCard.frame.x, newCard.frame.y = 0, -cardHeight*0.175 - 2

    -- newCard.energy = display.newImageRect(newCard, "Resources/Images/Cards/" .. data.energy, 20 ,20)
    -- newCard.energy.x, newCard.energy.y = 20, 3

	local bg = newCard.background

    newCard.energyCost = display.newText(newCard, data.energy, bg.width*0.5 - 12, -bg.height*0.5 + 4, settings.userdata.font, 25)
	newCard.energyCost.anchorX, newCard.energyCost.anchorY = 1, 0

    -- newCard.name = display.newText(newCard, cardName, 30, 22, titleWidth, titleHeight, settings.userdata.font, 10)

    -- newCard.description = display.newText(newCard, data.description, 5, 60 , textWidth, textHeight, settings.userdata.font, 7)

    newCard.back = display.newImageRect( newCard, "Resources/Images/Cards/cardBack.png", cardWidth, cardHeight )

	-- Kortin yleisiä tietoja:
    newCard.type = "card"
	newCard.name = cardName
	for k, v in pairs( data ) do
		newCard[k] = v
	end

    newCard:addEventListener("touch", selectCard)
    deck[#deck+1] = newCard

    return #deck
end

--drawing a card from the deck
function card.dealCards(event)
    if event.phase == "ended" then
        local cardNum = #deck
        if cardNum > 0 then
            playerHand[#playerHand+1] = deck[cardNum]
            deck[cardNum] = nil

            transition.to( playerHand[#playerHand], { time = 500, x = (#deck) * 120, y = display.contentHeight / 2 + 150 })
            transition.to( playerHand[#playerHand].back, { time = 500, alpha=0 })
            -- transition.to( playerHand[#playerHand].back.path, { time = 500, x1=40, x2=40, x3=-40, x4=-40 })

			-- TODO: Animoi korttien flippaus.
			-- NB! Tässä on sellainen ongelma, että path flippaus toimii vain objektien kanssa, joilla on path property.
			-- Tämä ei siis toimi esim. display grouppien tai containereiden kanssa ilman erillistä kikkailua.

            -- playerHand[#playerHand].back.path.x1 = 40
            -- playerHand[#playerHand].back.path.x2 = 40
            -- playerHand[#playerHand].back.path.x3 = -40
            -- playerHand[#playerHand].back.path.x4 = -40

            playerHand[#playerHand].inHand = true
        end
    end
    return true
end

function card.removeCard()
    local cardIndex
    for i = 1, #playerHand do
        if activeCard == playerHand[i] then
            cardIndex = i
            break
		end
    end
	--removing the active card from player hand when its played
	table.remove( playerHand, cardIndex )
end

function card.playCard( event )
    --print(event.phase, canPlayCard, activeCard)
    if event.phase == "began" and canPlayCard == true then
        if activeCard then
            canPlayCard = false
            print("Target type: " .. event.target.type, "Card target: " .. activeCard.target)

            --card is being played a.k.a removed from the screen
            if event.target.type == activeCard.target then
                print("Card played.")
                transition.to(activeCard, { time=500, x=700, y=300, onComplete=function()
                    card.removeCard()
                    activeCard = nil
                    canPlayCard = true
                end})

                return true

            else
                --if a card cannot be played to another card, switch active card
                if event.target.type == "card" then
                    print("Switching the active card.")
                    canPlayCard = true
                    return false
                else
                    --if card cannot be played like this, play error sound and animation
                    print("Can't play card.")
                    transition.to(activeCard, { time=500, x= activeCard.x+10, transition=easing.inOutBack, onComplete=function()
                        transition.to(activeCard, { time=500, x=activeCard.x-10, transition=easing.inOutBack, onComplete=function()
                            canPlayCard = true
                        end })
                    end })

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