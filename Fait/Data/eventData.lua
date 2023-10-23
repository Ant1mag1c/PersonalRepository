local userdata = require("Scripts.userdata")

return {
    --Malli eventti
    -- ["event.name"] = {
    --     isPositiveEvent = false,
    --     title = "",
    --     image = "",
    --     description = "",
    --     event = {
    --         {
    --             option = "",
    --             action = function()
    --                 return ""
    --             end,

    --         },
    --         {
        --             option = "",
        --             action = function()
        --                 return ""
    --             end,

    --         }
    --     }
    -- },


    -- Nämä eventit ovat valmiita
    ------------------------------------------------------------------------------------------

    ["luola"] = {
        isPositiveEvent = false,
        title = "Dark Cave",
        image = "darkcave.png",
        description = "You spot a mysterious cave. What will you do? Explore in hopes of treasure while risking a battle or leave it be?",
        event = {
            {
                option = "Explore the cave",
                action = function()
                    local result
                    local nextScene
                    local chance = math.random()
                    local params

                    if chance < 0.5 then
                        params = {
                            enemy = "hamahakki",
                            enemyCount = math.random( 1, 2 )
                        }

                        result = "You hear some crawling sound withing the darkness "
                        nextScene = "battle"
                    else
                        result = "You see a goldish glow withing the darkness "
                        nextScene = "treasure"
                    end

                    return  result, nextScene, params
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

    ["avohaava"] = {
        isPositiveEvent = false,
        title = "Open Wound",
        image = "openwound.png",
        description = "You have a nasty wound. Your sisu movement cost has been increased",
        event = {
            {
                option = "Keep moving",
                action = function()
                    local bleedAmmount = math.random( userdata.bleedDmgMin, userdata.bleedDmgMax )
                    local bleedDuration = math.random( 10, 20 )

                    userdata.player.sisuCurrent = userdata.player.sisuCurrent - bleedAmmount
                    userdata.player.bleedCount = userdata.player.bleedCount + bleedDuration

                    return "You lost " .. bleedAmmount .. " sisu and you are now bleeding for " .. bleedDuration .. " turns."
                end
            }
        }
    },

    ["mustamarja"] = {
        isPositiveEvent = "neutral",
        title = "Black Berries",
        image = "blackberries.png",
        description = "You feel hunger crows and desperately search for sustenance. You spot a bush of black, unknown berries. Will you risk it?",
        event = {
            {
                option = "Eat the berries",
                action = function()
                    local r = math.random()

                    if r < 0.5 then
                        -- pelaaja saa sisua
                        r = math.random( 15, 30 )
                        userdata.player.sisuCurrent = math.min( userdata.player.sisuMax, userdata.player.sisuCurrent + r )
                        return "Your berries were tasty. You healed for +" .. r .. " sisu"
                    else
                        -- Pelaaja ottaa vahinkoa
                        r = math.random( 1, 30 )
                        userdata.player.sisuCurrent = userdata.player.sisuCurrent - r

                        return "Your berries were toxic. You lost " .. r .. " ammount of sisu"
                    end
                end
            },
            {
                option = "Leave the bush alone",
                action = function()
                    return "Better safe than sorry"
                end
            }
        }
    },


    ["leirinta-alue"] = {
        isPositiveEvent = true,
        title = "Campsite",
        image = "campsite.png",
        description = "You are able to take a short nap. Resting at the campsite heals you a little.",
        event = {
            {
                option = "Take a nap",
                action = function()
                    userdata.player.sisuCurrent = math.min( userdata.player.sisuMax, userdata.player.sisuCurrent + 15 )

                    return "You healed for +15"
                end,
            }
        }
    },


    ["lonkero"] = {
        isPositiveEvent = true,
        title = "cider",
        image = "cider.png",
        description = "Your found a unopened can of cider lying on the ground. Finders keepers",
        event = {
            {
                option = "Drink the cider",
                action = function()
                    userdata.player.moveReductionCount = userdata.player.moveReductionCount + 5

                    return "Your feet feels light. Movement penalty decreased for 5 turns"
                end,
            }
        }
    },

    ["revontulet"] = {
        isPositiveEvent = "neutral",
        title = "Aurora Borealis",
        image = "auroraborealis.png",
        description = "You catch a glimpse of Aurora Borealis. A gorgerous streams of lighting dancing on the sky",
        event = {
            {
                option = "Admire the view for a moment",
                action = function()
                    userdata.player.goodEventCount =  userdata.player.goodEventCount + 2

                    return  "Your next 2 events will be on your side"
                end
            }
        }
    },


    ["makkaraperunat"] = {
        isPositiveEvent = true,
        title = "Sausage Potatoes",
        image = "sausagepotatoes.png",
        description = "Your deepest desires manifest a serving of loaded sausage potatoes in your hands.",
        event = {
            {
                option = "Eat sausage potatoes",
                action = function()
                    userdata.player.sisuCurrent = math.min( userdata.player.sisuMax, userdata.player.sisuCurrent + 100 )

                    return "You healed for +100"
                end,
            }
        }
    },


    ["avanto"] = {
        isPositiveEvent = true,
        title = "Hole in the ice",
        image = "holeinice.png",
        description = "You spot a nicely carved hole in the ice",
        event = {
            {
                option = "Take a dip ",
                action = function()
                    userdata.player.sisuMax = userdata.player.sisuMax + 15

                    return "Your max sisu has been increased for +15"
                end,
            }
        }
    },

    ["ruisleipä"] = {
        isPositiveEvent = true,
        title = "Rye Bread",
        image = "ryebread.png",
        description = "You stumble upon some rye bread. Eating it increases your attack.",
        event = {
            {
                option = "Eat the bread",
                action = function()
                    userdata.player.attack = userdata.player.attack + 1

                    return "Your attack has been increased +1!"
                end,
            }
        }
    },


    ["poppamies"] = {
        isPositiveEvent = true,
        title = "Shaman",
        image = "shaman.png",
        description = "The Shaman lets you increase one of you core stat. Choose wisely!",
        event = {
            {
                option = "Train for offence",
                action = function()
                    userdata.player.attack = userdata.player.attack + 1
                    return "Your attack has been increased +1!"
                end
            },
            {
                option = "Train for defence",
                action = function()
                    userdata.player.defense = userdata.player.defense + 1

                    return "Your defence has been increased +1!"
                end
            }
        }
    },


    ["sauna"] = {
        isPositiveEvent = true,
        title = "Sauna",
        image = "sauna.png",
        description = "You have entered Sauna! Choose between healing or increasing max sisu",
        event = {
            {
                option = "Heal",
                action = function()
                    userdata.player.sisuCurrent = math.min( userdata.player.sisuMax, userdata.player.sisuCurrent + 25 )
                    return "You healed for +25"
                end
            },
            {
                option = "Increase sisu",
                action = function()
                    userdata.player.sisuMax = userdata.player.sisuMax + 10
                    return "Your max sisu has been increased +10"
                end
            }
        }
    },


    ["piima"] = {
        isPositiveEvent = true,
        title = "Sour milk",
        image = "sourmilk.png",
        description = "You stumble upon some sour milk.",
        event = {
            {
                option = "Drink the sour milk ",
                action = function()
                    userdata.player.defense = userdata.player.defense + 1
                    return "Your defence has been increased +1!"
                end,
            }
        }
    },


    -- Näissä eventeissä kuva ok mutta koodi vielä kesken
-----------------------------------------------------------------------------------------

    -- ["korttienHautausmaa"] = {
        --     isPositiveEvent = false,
        --     title = "Card Cemetery",
        --     image = "cardcemetery.png",
        --     description = "You can choose between 1-3 cards to return from the cemetery to your hand.",
        --     event = {

        --         {
        --             option = "Choose the cards of to return in hand",
        --             action = function() end,
        --             result = ""
        --         }
        --     }
        -- },





    ["kapakka"] = {
            isPositiveEvent = false,
            title = "Tavern",
            image = "tavern.png",
            description = "You can purchase a variety of goodies including beer.",
            event = {
                {
                    option = "Enter the tavern",
                    action = function()

                        return ""
                    end,
                }
            }
        },


    ["treasure"] = {
        isPositiveEvent = false,
        title = "Treasure chest",
        image = "treasure.png",
        description = "Player can choose to pick a new card to his hand or gain some money",
        event = {
            {
                option = "Pick a card",
                action = function()

                    return "Move to pick card scene"
                end
            },
            {
                option = "Gain +15 money",
                action = function()
                    userdata.player.money = userdata.player.money + 15
                    return "You earned some pocket money"
                end
            }
        }
    },

    ["ansa"] = {
        isPositiveEvent = true,
        title = "Lynx Bite",
        image = "lynxbite.png",
        description = "Lynx appears from the shadows and attacks you by suprise.",
        event = {
            {
                option = "Remove a Card to avoid attack",
                action = function()

                    return "Move to remove card scene"
                end,
            },
            {
                option = "Accept your fate",
                action = function()
                    local bleedAmmount = math.random( userdata.bleedDmgMin, userdata.bleedDmgMax )
                    local bleedDuration = math.random( 3, 6 )

                    userdata.player.sisuCurrent = userdata.player.sisuCurrent - bleedAmmount
                    userdata.player.bleedCount = userdata.player.bleedCount + bleedDuration

                    return "You lost " .. bleedAmmount .. " sisu and you are now bleeding for " .. bleedDuration .. " turns."
                end
            }
        }
    },

    -- Näistä eventeissä koodi ok mutta kuva puuttuu
------------------------------------------------------------------------------------------

["lauma"] = {
    isPositiveEvent = false,
    title = "Wild Animals",
    image = "jokuKuva.png",
    description = "Some wild animals have gone hunting and you are their prey. Good luck.",
    event = {
        {
            option = "Draw your weapon",
            action = function()
                local nextScene = "battle"

                local params = {
                    enemy = "susi",
                    enemyCount = 2
                }

                return  "You hear loud howling right next to you", nextScene, params
            end,
        }
    }
},




    -- Näistä eventeissä koodi kesken ja ei kuvaa
------------------------------------------------------------------------------------------




    ["apteekki"] = {
        isPositiveEvent = true,
        title = "Infirmary",
        image = "jokuKuva.png",
        description = "You stubled upon infirmary. Choose what would you like to do",
            event = {
            {
                option = "Look for wares",
                action = function()
                    -- local params
                    local nextScene = "pharma"

                    local params = {
                        card = "ansa"
                    }

                    return "Move to store scene", nextScene, params
                end
            },
            {
                option = "Bandage your bleeding",
                action = function()
                    userdata.player.bleedCount = 0

                    return "You are no longer bleeding"
                end

            },
        }
    },

    -- ["nettles"] = {
    --     isPositiveEvent = false,
    --     title = "Nettles",
    --     image = "jokuKuva.png",
    --     description = "You become too in touch with the nature and step on some nettles. Soon you start itching. Next event you encounter is bad.",
    --     event = {

    --         {
    --             option = "Accept the fate",
    --             action = function() end,
    --             result = "Your next event won't make you happy"
    --         }
    --     }
    -- },



}