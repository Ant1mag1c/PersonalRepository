-- Piilotetaan statusbar simulaattorilla ja muilta alustoilta, joilla se löytyy:
display.setStatusBar( display.HiddenStatusBar )

require("scripts.utils")
screen = require("scripts.screen")

local composer = require("composer")

composer.gotoScene( "Scenes.game", { effect = "fade", time = 0, params = nil } )


--[[
    TODO!

    Luo omat funktiot vihollisen etäisyyden hakemiselle sekä kulman laskemiselle
    Viimeistele Leash() funktio

--]]
