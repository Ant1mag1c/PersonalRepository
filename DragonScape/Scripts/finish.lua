local finish = {}

-- Kuten enemy.lua ja player.lua tiedostoissa, tässä tiedostossa luodaan uusi vihollinen.
-- Tarkempia selityksiä voit katsoa enemy.lua tai player.lua tiedostoista.

function finish.new( parent, finishRef )
	local x, y = finishRef.x, finishRef.y
	display.remove( finishRef )

	local options =
	{
		-- The params below are required
		width = 18,
		height = 18,
		numFrames = 64,
	}
	local imageSheet = graphics.newImageSheet( "Maps/Tiles/tilemap.png", options )

	-- Toisin kuin enemy.lua ja player.lua tiedostoissa, tässä tiedostossa ei luoda sprite objektia. Tämä tarkoittaa,
	-- että "finish" ei ole animaatio, vaan pelkästään yksi kuva, joka on otettu sprite sheetistä.
	local newFinish = display.newImageRect( parent, imageSheet, finishRef.tileNum, 18, 18 )
	newFinish.isVisible = false
	newFinish.x, newFinish.y = x, y-30
	newFinish.tileType = "finish"

	physics.addBody( newFinish, "static", { bounce = 0, isSensor=true } )

	return newFinish
end



return finish