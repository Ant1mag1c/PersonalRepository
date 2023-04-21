display.setStatusBar( display.HiddenStatusBar )

local cardScript = require("Scripts.Card")
local enemyScript = require("Scripts.Enemy")
local card = {}
local player = {}

card[1] = cardScript.newCard( "testCard1")
card[2] = cardScript.newCard( "testCard2")
card[3] = cardScript.newCard( "testCard3")
card[4] = cardScript.newCard( "testCard4")
card[5] = cardScript.newCard( "testCard5")


cardScript.dealCards()

player = display.newRect( 150, 250, 50 , 50)
player:setFillColor(0,1,0)
player.type = "player"

player:addEventListener("touch", cardScript.playCard)

enemyScript.newEnemy()
