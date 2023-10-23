local player = {}

local userdata = require("Scripts.userdata")
local playerStatusBar = require("Widgets.playerStatusBar")
local cardScript = require("Scripts.Card")

local playerScale = 0.5
local statusBarPaddingHorizontal = 20
local statusBarPaddingVertical = 20


function player.newPlayer( parent, x, y )
	x, y = x or 0, y or 0

	local newPlayer = display.newImage( parent, "Resources/Images/Characters/" .. userdata.player.imageBattle, x, y )
	newPlayer.xStart, newPlayer.yStart = x, y
	newPlayer.startScale = playerScale
	newPlayer:scale( playerScale, playerScale )

	newPlayer.stats = display.newText({
		parent = parent,
		text = "",
		x = newPlayer.x,
		y = newPlayer.y + newPlayer.height*0.5 + 20,
		font = native.systemFont,
		fontSize = 24,
	})

	newPlayer.statsBG = display.newRect( parent, newPlayer.stats.x, newPlayer.stats.y, newPlayer.stats.width + 20, newPlayer.stats.height + 20 )
	newPlayer.statsBG:setFillColor( 0, 0.8 )
	newPlayer.statsBG.isVisible = false
	newPlayer.stats:toFront()

	-- status efektit tallennetaan jokaiseen viholliseen erikseen ja niitä päivitetään jokaisen vuoron alussa.
	newPlayer.statusEffect = {}

	function newPlayer:addStatusEffect( statusEffect )
		newPlayer.statusEffect[#newPlayer.statusEffect+1] = statusEffect
	end

	function newPlayer:updateStatus()
		-- local listOfStatuses = {}
		if #self.statusEffect > 0 then
			for i = #self.statusEffect, 1, -1 do
				-- update on jokaisen status effectin mukana taulukossa oleva funktio.
				local expired = self.statusEffect[i].update()
				if expired then
					table.remove( self.statusEffect, i )
				end
			end
		end

		userdata.player.energy = userdata.player.energyRegen

		-- Pelaajan tila päivitetään playerStatusBar moduulissa.
		playerStatusBar.update()

		-- Vain erilliset status efektit näytetään pelaajan päällä.
		if #self.statusEffect > 0 then
			self.stats.text = "Status effects: ?"
			newPlayer.statsBG.isVisible = true

			self.statsBG.width = self.stats.width + statusBarPaddingHorizontal
			self.statsBG.height = self.stats.height + statusBarPaddingVertical

		else
			newPlayer.statsBG.isVisible = false
		end


		if userdata.player.sisuCurrent <= 0 then
			self.isDead = true
			display.remove( self.stats )
			display.remove( self.statsBG )
			display.remove( self )
		end
	end

    newPlayer:addEventListener("touch", cardScript.playCard)
    newPlayer.type = "player"

    return newPlayer
end

return player