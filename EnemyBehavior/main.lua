-- Piilotetaan statusbar simulaattorilla ja muilta alustoilta, joilla se löytyy:
display.setStatusBar( display.HiddenStatusBar )

require("scripts.utils")
screen = require("scripts.screen")

local composer = require("composer")

composer.gotoScene( "Scenes.game", { effect = "fade", time = 0, params = nil } )

