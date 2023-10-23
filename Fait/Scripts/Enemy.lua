local enemy = {}

local cardScript = require("Scripts.Card")

local statusBarPaddingHorizontal = 20
local statusBarPaddingVertical = 20

function enemy.newEnemy( parent, x, y, enemyData )
	x, y = x or 0, y or 0

	local newEnemy = display.newImage( parent, "Resources/Images/Enemies/" .. enemyData.image, x, y )
	newEnemy.xStart, newEnemy.yStart = x, y
	newEnemy.startScale = newEnemy.xScale

	-- Jos kuvaa ei löydy, niin luodaan debug kuva tilalle, ettei peli kaadu.
	if not newEnemy then
		newEnemy = display.newRect( parent, x, y, 200, 200 )
		newEnemy:setFillColor( 0 )

		local name = display.newText( parent, enemyData.name, newEnemy.x, newEnemy.y, native.systemFont, 24 )
		local scale = math.min( (newEnemy.width - 40) / name.width, 1 )
		name:scale( scale, scale )
	end

	newEnemy.name = enemyData.name
	newEnemy.alignment = enemyData.alignment
	newEnemy.hp = math.random( enemyData.minHP, enemyData.maxHP ) or 10
	newEnemy.minAttack = enemyData.minAttack or enemyData.maxAttack or 1
	newEnemy.maxAttack = enemyData.maxAttack or enemyData.minAttack or 1
	newEnemy.defense = enemyData.defense or 0

	newEnemy.stats = display.newText({
		parent = parent,
		text = enemyData.name .. " - HP: " .. newEnemy.hp .. ", ATK: " .. newEnemy.minAttack .. "-" .. newEnemy.maxAttack .. ", DEF: " .. newEnemy.defense,
		x = newEnemy.x,
		y = newEnemy.y + newEnemy.height*0.5 + 20,
		font = native.systemFont,
		fontSize = 24,
	})

	newEnemy.statsBG = display.newRect( parent, newEnemy.stats.x, newEnemy.stats.y, newEnemy.stats.width + statusBarPaddingHorizontal, newEnemy.stats.height + statusBarPaddingVertical )
	newEnemy.statsBG:setFillColor( 0, 0.8 )
	newEnemy.stats:toFront()

	-- status efektit tallennetaan jokaiseen viholliseen erikseen ja niitä päivitetään jokaisen vuoron alussa.
	newEnemy.statusEffect = {}

	function newEnemy:addStatusEffect( statusEffect )
		newEnemy.statusEffect[#newEnemy.statusEffect+1] = statusEffect
	end

	function newEnemy:updateStatus()
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

		-- Päivitä lopuksi vihollisen luvut.
		self.stats.text = self.name ..
			" - HP: " .. self.hp ..
			", ATK: " .. self.minAttack .. "-" .. self.maxAttack ..
			", DEF: " .. self.defense ..
			(#self.statusEffect > 0 and "\nStatus effects: ?" or "")

		self.statsBG.width = self.stats.width + statusBarPaddingHorizontal
		self.statsBG.height = self.stats.height + statusBarPaddingVertical

		if self.hp <= 0 then
			self.isDead = true
			display.remove( self.stats )
			display.remove( self.statsBG )
			display.remove( self )
		end
	end

	-- TODO: lisätään vihollisen puuttuvat aktiiviset ja passiiviset ominaisuudet, jne.

    newEnemy:addEventListener("touch", cardScript.playCard)
    newEnemy.type = "enemy"

    return newEnemy
end

return enemy