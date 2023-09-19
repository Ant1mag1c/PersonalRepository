local enemy = {}

local cardScript = require("Scripts.Card")

function enemy.newEnemy( parent, x, y, enemyData )
	x, y = x or 0, y or 0

	local newEnemy = display.newImage( parent, "Resources/Images/Enemies/" .. enemyData.image, x, y )

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
	newEnemy.hp = math.random( enemyData.minHP, enemyData.maxHP )
	newEnemy.dmg = math.random( enemyData.minAttack, enemyData.maxAttack )

	-- TODO: lisätään vihollisen puuttuvat aktiiviset ja passiiviset ominaisuudet, jne.

    newEnemy:addEventListener("touch", cardScript.playCard)
    newEnemy.type = "enemy"

    return newEnemy
end

return enemy