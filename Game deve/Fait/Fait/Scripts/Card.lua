local card = {}
local playerHand = {}
local deck = {}
local activeCard
local canPlayCard = true
local cardData = require("Data.CardData")

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
    if canPlayCard then
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
function card.newCard( cardType, x, y )
    local cardWidth = 80
    local cardHeight = 120

    local textWidth = 65
    local textHeight = 70

    local titleWidth = 100
    local titleHeight = 20

    local newCard = display.newGroup()
    newCard.x, newCard.y = x, y

    local data = cardData[cardType]

    newCard.background = display.newImageRect( newCard, "Resources/Images/Cards/cardFront.png", cardWidth, cardHeight )

    newCard.image = display.newImageRect(newCard,"Resources/Images/Cards/" .. data.image, 65, 65)
    newCard.image.x, newCard.image.y = 0, -cardHeight*0.175

    newCard.frame = display.newImageRect(newCard, "Resources/Images/Cards/" .. data.frame, 78, 78 )
    newCard.frame.x, newCard.frame.y = 0, -cardHeight*0.175 - 2

    newCard.energy = display.newImageRect(newCard, "Resources/Images/Cards/" .. data.energy, 20 ,20)
    newCard.energy.x, newCard.energy.y = 20, 3

    newCard.energyCost = display.newText(newCard, data.cost, 21, 3, native.systemFont, 25)

    newCard.name = display.newText(newCard, data.name, 30, 22, titleWidth, titleHeight, native.systemFont, 10)

    newCard.description = display.newText(newCard, data.description, 5, 60 , textWidth, textHeight, native.systemFont, 7)

    newCard.back = display.newImageRect( newCard, "Resources/Images/Cards/cardBack.png", cardWidth, cardHeight )

    newCard.type = "card"

    newCard.target = data.target

    newCard:addEventListener("touch", selectCard)
    deck[#deck+1] = newCard
    return #deck
end

--drawing a card from the deck
function card.dealCards(event)
    print("jaetaan kortti")
    if event.phase == "ended" then
        local cardNum = #deck
        if cardNum > 0 then
            playerHand[#playerHand+1] = deck[cardNum]
            deck[cardNum] = nil
            transition.to( playerHand[#playerHand], { x = (#deck) * 90, y = display.contentHeight / 2 + 150, time = 500 })
        end
    end
    return true
end

function card.removeCard()
    local cardIndex
    for i = 1, #playerHand do
        if activeCard == playerHand[i] then
            cardIndex = i
            break end
            --removing the active card from player hand when its played
            table.remove( playerHand, cardIndex ) 
    end  
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