local bar = {}

local screen = require("Scripts.screen")
local settings = require("Scripts.settings")
local userdata = require("Scripts.userdata")

local menuButton
local UI

function bar.create( parent, menuButtonReference )
	if not UI then
		UI = display.newGroup()
		parent:insert( UI )

		UI.bg = display.newRect( UI, screen.centerX, screen.minY, screen.width, 40 )
		UI.bg.anchorY = 0
		UI.bg:setFillColor( 0.2 )

		-- Pidä viittaus menu nappiin, jotta se voidaan myös aina päivittää
		-- ja tuoda playerStatusBarin eteen update() kutsun yhteydessä.
		menuButton = menuButtonReference

		bar.update()
	end
end


function bar.update()
	if UI then
		if UI.text then
			for i = 1, #UI.text do
				display.remove( UI.text[i] )
			end
		else
			UI.text = {}
		end

		local playerData = userdata.player

		local contents = {
			"SISU: " .. playerData.sisuCurrent .. "/" .. playerData.sisuMax,
			"ENERGY: " .. playerData.tempEnergy,
			"ATTACK: " .. playerData.attack,
			"DEFENSE: " .. playerData.defense,
			"MONEY: " .. playerData.money,
			"CARDS: " .. #playerData.cards .. "/" .. playerData.maxCardsDeck,
			"MAP: " .. (playerData.currentMap or "?"),
		}

		local padding = 20
		local x = screen.minX + 10
		local offsetY = 0

		for i = 1, #contents do
			UI.text[i] = display.newText( UI, contents[i], x, UI.bg.y + UI.bg.height*0.5 + offsetY, settings.userdata.font, 17 )
			UI.text[i].anchorX = 0

			x = x + UI.text[i].width + padding
		end

		UI:toFront()
		menuButton:toFront()
	end
end


function bar.destroy()
	display.remove( UI )
	UI = nil
	-- Poistetaan vain viittaus nappiin.
	-- Nappi poistuu omassa scenessään.
	menuButton = nil
end


return bar