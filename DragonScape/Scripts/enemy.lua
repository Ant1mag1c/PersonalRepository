local enemy = {}

-- Erillinen funktio, jolla voidaan luoda vihollisia:
function enemy.new( parent, enemyRef )
	-- enemyRef on kartassa oleva tile, joka käytetään viittauksena (reference). Tästä otetaan ylös
	-- vihollisen haluttu sijainti ja sen jälkeen poistetaan tile kartalta.
	local x, y = enemyRef.x, enemyRef.y
	display.remove( enemyRef )

	-- Tehdään viholliselle uusi imageSheet, joka sisältää kaikki vihollisen animaatiot:
	local options =
	{
		-- The params below are required
		width = 24,
		height = 24,
		numFrames = 16,
	}
	local imageSheet = graphics.newImageSheet( "Images/characterAnimations.png", options )

	-- Luodaan data taulukko ja täytetään se vihollisen tyypin mukaan esim. frame, physics body ja animaatio tiedoilla.
	local data = {}
	local enemyType = enemyRef.enemyType

	if enemyType == "bat" then
		data.frame = 12
		data.body = "kinematic"
		data.animation = {
			{
				name = "move",
				start = data.frame,
				count = 3,
				time = 500,
				loopCount = 0,
				loopDirection = "forward"
			}
		}

	elseif enemyType == "spikey" then
		data.frame = 9
		data.body = "dynamic"

		data.animation = {
			{
				name = "move",
				start = data.frame,
				count = 3,
				time = 500,
				loopCount = 0,
				loopDirection = "forward"
			}
		}

	elseif enemyType == "block" then
		-- "block" tyypin vihollista ei tehty.

	end

	-- Tehdään sprite objekti ja liitetään se display grouppiin.
	local newEnemy = display.newSprite( imageSheet, data.animation )
	parent:insert( newEnemy )

	-- Käynnistetään "move" animaatio.
	newEnemy:setSequence( "move" )
	newEnemy:play()

	newEnemy.x, newEnemy.y = x, y
	newEnemy.tileType = "enemy"

	-- Lisätään fysiikat viholliselle.
	physics.addBody( newEnemy, data.body, { bounce = 0, radius=newEnemy.width*0.5 } )

	-- Palautetaan viittaus "newEnemy" objektiin, eli luomaamme viholliseen.
	return newEnemy
end



return enemy