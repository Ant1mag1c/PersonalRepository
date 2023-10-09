local userdata = {}

local loadsave = require( "Libs.loadsave" )
local dataHandler = require("Scripts.dataHandler")
local characterData = dataHandler.getData( "playerCharacters.tsv" )
local cardData = dataHandler.getData( "cards.tsv" )
local defaultStats = require("Data.defaultStats")


function userdata.save()
    loadsave.save( userdata.player, "userdata.json", "cardevala" )

end

function userdata.load()
    userdata.player = loadsave.load( "userdata.json", "cardevala" )

    return not not userdata.player
end

function userdata.new(params)
    params = params or {}

    local playerClass = params.playerClass or "puukkojunkkari"

    userdata.player = characterData[playerClass]

    if not userdata.player then
        print("ERROR: playerClass " .. tostring(playerClass) .. " does not exist")
    end

    userdata.player.playerClass = playerClass

    -- Hahmokohtaisia ja devaajan muokattavissa olevia statseja
    userdata.player.defense = tonumber( params.defense or userdata.player.defense )
    userdata.player.tempEnergy = tonumber( params.tempEnergy or userdata.player.tempEnergy )
    userdata.player.sisuMax = tonumber( params.sisu or userdata.player.sisu )
    userdata.player.startingCards = tonumber( params.startingCards or userdata.player.startingCards )
    userdata.player.attack = tonumber( params.attack or userdata.player.attack )
    userdata.player.bleedCount = userdata.bleedCount or 0
    userdata.player.moveReductionCount = 0
    userdata.player.goodEvents = {}



    -- Luodaa muita default / aloitus statseja
    userdata.player.sisuCurrent = tonumber( userdata.player.sisuMax )
    userdata.player.money = tonumber( defaultStats.money ) -- TODO: Tämän voi varmaan siirtää hahmokohtaisiin statseihin?
    userdata.player.maxCardsDeck = tonumber( defaultStats.maxCardsDeck )
    userdata.player.maxCardsHand = tonumber( defaultStats.maxCardsHand )
    userdata.player.cardPerTurn = tonumber( defaultStats.cardPerTurn )

    userdata.bleedDmgMin, userdata.bleedDmgMax = 1, 5

    -- Annetaan pelaajalle kortit
    local quaranteedCard = params.guaranteedCard or userdata.player.guaranteedCard
    local cardCount = tonumber( params.startingCards or userdata.player.startingCards )

    userdata.player.cards = {quaranteedCard}

    -- TODO: Varmista että pelaaja saa kaikentyyppisiä kortteja

	local allowedCards = {}
	for k, v in pairs( cardData ) do
		if v.firstMap <= 1 and v.lastMap >= 1 then
			allowedCards[#allowedCards+1] = k
		end
	end

    for i = 2, cardCount do
        userdata.player.cards[i] = table.getRandom(allowedCards)
    end


end


return userdata