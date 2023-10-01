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
    --     }
    -- },

    -- ["nettles"] = {
    --     id = "",
    --     title = "Nettles",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You become too in touch with the nature and step on some nettles. Soon you start itching. Next event you encounter is bad.",
    --     event = {
    --
    --         {
    --             option = "Accept the fate",
    --             action = function() end,
    --             result = "Your next event won't make you happy"
    --         }
    --     }
    -- },

    -- ["mustamarja"] = {
    --     id = "",
    --     title = "Black Berries",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You feel hunger getting deeper and desperately search for sustenance. You spot a bush of black, unknown berries. Will you risk it?",
    --     event = {
    --         {
    --             option = "Eat the berries",
    --             action = function()  end,
    --             result = ""
    --         },

    --         {
    --             option = "Leave the bush alone",
    --             action = function() end,
    --             result = "Better safe than sorry"
    --         }
    --     }
    -- },

    -- ["lonkero"] = {
    --     id = "",
    --     title = "Tentacles",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "Your found a unopened bottle of cider lying on the ground. Finders keepers",
    --     event = {
    --
    --         {
    --             option = "Drink the cider",
    --             action = function() end,
    --             result = "Your movement sisu costs have been decreased by 3 for next 5 moves."
    --         }
    --     }
    -- },



    -- ["apteekki"] = {
    --     id = "",
    --     title = "Infirmary",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "Got some wounds to heal? Look no further, you can pay to fix yourself right up.",
    --     event = {
    --
    --         {
    --             option = "Enter in infirmary",
    --             action = function() end,
    --             result = 0
    --         }
    --     }
    -- },

    -- ["avohaava"] = {
    --     id = "",
    --     title = "Open Wound",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You have a nasty wound. Your sisu movement cost has been increased",
    --     event = {
    --         {
    --             option = "Keep moving",
    --             action = function() return end,
    --             result = "Your movement penalty has been increased +3!"
    --         },

    --         {
    --             option = "",
    --             action = function() end,
    --             result = ""
    --         }
    --     }
    -- },

    -- ["onnenlantti"] = {
    --     id = "",
    --     title = "Aurora Borealis",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You catch a glimpse of Aurora Borealis. It blesses you. The next few events you encounter are guaranteed to be good.",
    --     event = {
    --
    --         {
    --             option = "I feel blessed",
    --             action = function() end,
    --             result = "Your next 2 events will be on your side"
    --         }
    --     }
    -- },

    -- ["lauma"] = {
    --     id = "",
    --     title = "Wild Animals",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "Some wild animals have gone hunting and you are their prey. Good luck.",
    --     event = {
    --
    --         {
    --             option = "Draw your weapon",
    --             action = function() end,
    --             result = 0
    --         }
    --     }
    -- },

    -- ["kapakka"] = {
    --     id = "",
    --     title = "Tavern",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You can purchase a variety of goodies including beer.",
    --     event = {
    --         {
    --             option = "Enter the tavern",
    --             action = function()  end,
    --             result = 0
    --         }
    --     }
    -- },

    ["luola"] = {
        id = "",
        title = "Dark Cave",
        image = "jokuKuva.png",
        imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
        description = "You spot a mysterious cave. What will you do? Explore in hopes of treasure while risking a battle or leave it be?",
        event = {
            {
                option = "Explore the cave",
                action = function()
                    local result
                    local chance = math.random()
                    if chance < 0.3 then
                        result = "Huono tuuri"
                    else
                        result = "hyvä tuuri"
                    end

                    return "You entered cave with chance: " .. result
                end,

            },

            {
                option = "Exit the cave",
                action = function()
                    return "You left the cave in peace"
                end
            }
        }
    },


    -- ["ansa"] = {
    --     -- id = "",
    --     title = "Lynx Bite",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "Lynx appears from the shadows and attacks you. Your quick manoeuvres allow you to either lose 10 sisu and gain bleed for 5 turns or send one card into the cemetery.",
    --     event = {
    --         {
    --             option = "Remove a Card",
    --             action = function() return end,
    --             result = 1
    --         },

    --         {
    --             option = "Take damage and gain bleed",
    --             action = function()
    --                 local bleedAmmount = math.random( userdata.bleedDmgMin, userdata.bleedDmgMax )
    --                 local bleedDuration = math.random( 1, 2 )

    --                 userdata.player.sisuCurrent = userdata.player.sisuCurrent - bleedAmmount
    --                 userdata.player.bleedCount = userdata.player.bleedCount + bleedDuration

    --                 return "You lost " .. bleedAmmount .. " sisu and you are now bleeding for " .. bleedDuration .. " turns."
    --             end
    --         }
    --     }
    -- },

    -- ["korttienHautausmaa"] = {
    --     id = "",
    --     title = "Card Cemetery",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You can choose between 1-3 cards to return from the cemetery to your hand.",
    --     event = {
    --
    --         {
    --             option = "Choose the cards of to return in hand",
    --             action = function() end,
    --             result = ""
    --         }
    --     }
    -- },

    -- ["makkaraperunat"] = {
    --         -- id = "",
    --         title = "Sausage Potatoes",
    --         image = "jokuKuva.png",
    --         imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --         description = "Your deepest desires manifest a serving of loaded sausage potatoes in your hands. Your hunger is satiated and you heal 100 sisu.",
    --         event = {

    --             {
    --                 option = "Eat sausage potatoes",
    --                 action = function() userdata.player.sisuCurrent = math.min(userdata.player.sisuMax, userdata.player.sisuCurrent + 100) end,
    --                 result = "You healed for +100"
    --             }
    --         }
    --     },

    -- ["avanto"] = {
    --     -- id = "",
    --     title = "Hole in the ice",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You spot a nicely carved hole in the ice and go swimming. The shivering cold increases your max sisu.",
    --     event = {

    --         {
    --             option = "Take a dip ",
    --             action = function() userdata.player.sisuMax = userdata.player.sisuMax + 15 end,
    --             result = "Your sisu has been increased +15"
    --         }
    --     }
    -- },



    -- ["leirinta-alue"] = {
    --     -- id = "",
    --     title = "Campsite",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You are able to take a short nap. Resting at the campsite heals you a little.",
    --     event = {

    --         {
    --             option = "Take a nap",
    --             action = function() userdata.player.sisuCurrent = math.min(userdata.player.sisuMax, userdata.player.sisuCurrent + 15) end,
    --             result = "You healed for +15"
    --         }
    --     }
    -- },

    -- ["ruisleipä"] = {
    --     -- id = "Rye Bread",
    --     title = "Rye Bread",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "You stumble upon some rye bread. Eating it increases your attack.",
    --     event = {

    --         {
    --             option = "Eat the bread",
    --             action = function() userdata.player.attack = userdata.player.attack + 1  end,
    --             result = "Your attack has been increased +1!"
    --         }
    --             }
    -- },

    -- ["poppamies"] = {
    --     -- id = "poppamies",
    --     title = "Shaman",
    --     image = "jokuKuva.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "The Shaman lets you increase your attack or defence. Choose wisely!",
    --     event = {
    --         {
    --             option = "Train for offence",
    --             action = function() userdata.player.attack = userdata.player.attack + 1  end,
    --             result = "Your attack has been increased +1!"
    --         },

    --         {
    --             option = "Train for defence",
    --             action = function() userdata.player.defense = userdata.player.defense + 1 end,
    --             result = "Your defence has been increased +1!"
    --         }
    --     }
    -- },

    -- ["treasure"] = {
    --     -- id = "treasure",
    --     title = "Treasure chest",
    --     image = "treasure.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.55},
    --     description = "Player can choose to pick a new card to his hand or gain some money",
    --     event = {
    --         {
    --             option = "Pick a card",
    --             action = function() print("Move to pick card scene") end,
    --             result = 0
    --         },

    --         {
    --             option = "Gain +15 money",
    --             action = function() userdata.player.money = userdata.player.money + 15 end,
    --             result = "You earned some pocket money"
    --         }
    --     }
    -- },

    -- ["sauna"] = {
    --     -- id = "sauna",
    --     title = "Sauna",
    --     image = "sauna.png",
    --     imageSize = {imageWidth = 300*0.7, imageHeight = 600*0.7, anchorY = 0.35},
    --     description = "You have entered Sauna! Choose between healing or increasing max sisu",
    --     event = {
    --         {
    --             option = "Heal",
    --             action = function() userdata.player.sisuCurrent = math.min(userdata.player.sisuMax, userdata.player.sisuCurrent + 25) end,
    --             result = "You healed for +25",
    --         },

    --         {
    --             option = "Increase sisu",
    --             action = function() userdata.player.sisuMax = userdata.player.sisuMax + 10 end,
    --             result = "Your sisu has been increased +10"
    --         }
    --     }
    -- },

    -- ["piima"] = {
    --     -- id = "armor",
    --     title = "Sour milk",
    --     image = "piima.png",
    --     imageSize = {imageWidth = 300, imageHeight = 600, anchorY = 0.35},
    --     description = "You stumble upon some sour milk. Drinking it increases your defence.",
    --     event = {
    --         {
    --             option = "Drink the sour milk ",
    --             action = function() userdata.player.defense = userdata.player.defense + 1 end,
    --             result = "Your defence has been increased +1!",
    --         }


    --     }
    -- },




}