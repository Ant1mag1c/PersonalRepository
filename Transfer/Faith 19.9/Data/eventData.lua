-- userdata.player.defense = tonumber( params.defense or userdata.player.defense )
--     userdata.player.tempEnergy = tonumber( params.tempEnergy or userdata.player.tempEnergy )
--     userdata.player.sisuMax = tonumber( params.sisu or userdata.player.sisu )
--     userdata.player.startingCards = tonumber( params.startingCards or userdata.player.startingCards )
--     userdata.player.attack = tonumber( params.attack or userdata.player.attack )

--     -- Luodaa muita default / aloitus statseja
--     userdata.player.sisuCurrent = tonumber( userdata.player.sisuMax )
--     userdata.player.money = tonumber( defaultStats.money ) -- TODO: Tämän voi varmaan siirtää hahmokohtaisiin statseihin?
--     userdata.player.maxCardsDeck = tonumber( defaultStats.maxCardsDeck )
--     userdata.player.maxCardsHand = tonumber( defaultStats.maxCardsHand )
--     userdata.player.cardPerTurn = tonumber( defaultStats.cardPerTurn )

local userdata = require("Scripts.userdata")

return {
    -- ["event.name"] = {
    --     id = "",
    --     title = "",
    --     image = "",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "",
    --     event = {
    --         {
    --             option = "",
    --             action = function()  end,
    --             result = "" or 0
    --         },

    --         {
    --             option = "",
    --             action = function() end,
    --             result = ""
    --         }
    --             }
    -- },

    -- ["event.name"] = {
    --     id = "",
    --     title = "",
    --     image = "",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "",
    --     event = {
    --         {
    --             option = "",
    --             action = function()  end,
    --             result = "" or 0
    --         },

    --         {
    --             option = "",
    --             action = function() end,
    --             result = ""
    --         }
    --             }
    -- },

    -- ["event.name"] = {
    --     id = "",
    --     title = "",
    --     image = "",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "",
    --     event = {
    --         {
    --             option = "",
    --             action = function()  end,
    --             result = "" or 0
    --         },

    --         {
    --             option = "",
    --             action = function() end,
    --             result = ""
    --         }
    --             }
    -- },

    -- ["event.name"] = {
    --     id = "",
    --     title = "",
    --     image = "",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "",
    --     event = {
    --         {
    --             option = "",
    --             action = function()  end,
    --             result = "" or 0
    --         },

    --         {
    --             option = "",
    --             action = function() end,
    --             result = ""
    --         }
    --             }
    -- },

    ["poppamies"] = {
        -- id = "poppamies",
        title = "Shaman",
        image = "jokuKuva.png",
        imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
        description = "The Shaman lets you increase your attack or defence. Choose wisely!",
        event = {
            {
                option = "Increase attack",
                action = function() userdata.player.attack = userdata.player.attack + 1  end,
                result = "Your attack has been increased +1!"
            },

            {
                option = "Increase defence",
                action = function() userdata.player.defense = userdata.player.defense + 1 end,
                result = "Your defence has been increased +1!"
            }
                }
    },

    ["treasure"] = {
        -- id = "treasure",
        title = "Treasure chest",
        image = "treasure.png",
        imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
        description = "Player can choose to pick a new card to his hand or gain some money",
        event = {
            {
                option = "Pick a card",
                action = function() print("Move to pick card scene") end,
                result = 0
            },

            {
                option = "Gain +15 money",
                action = function() userdata.player.money = userdata.player.money + 15 end,
                result = "You earned some pocket money"
            }
                }
    },

    ["sauna"] = {
        -- id = "sauna",
        title = "Sauna",
        image = "sauna.png",
        imageSize = {imageWidth = 300*0.7, imageHeight = 600*0.7, anchorY = 0.35},
        description = "You have entered Sauna! Choose between healing or increasing max sisu",
        event = {
            {
                option = "Heal",
                action = function() userdata.player.sisuCurrent = math.min(userdata.player.sisuMax, userdata.player.sisuCurrent + 25) end,
                result = "You healed for +25",
            },

            {
                option = "Increase sisu",
                action = function() userdata.player.sisuMax = userdata.player.sisuMax + 10 end,
                result = "Your sisu has been increased + 10"
            }
                }

        },

        ["armor"] = {
            -- id = "armor",
            title = "Armor plate",
            image = "armor.png",
            imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.35},
            description = "You found a piece of metal lying on the ground and picked it up",
            event = {
                {
                    option = "Increase defence ",
                    action = function() userdata.player.defense = userdata.player.defense + 1 end,
                    result = "Your defence has been increased +1!",
                }


                    }

            },




        }