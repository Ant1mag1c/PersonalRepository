local gamedata = require( "Scripts.gamedata" )

local player = {}


function player.new( parent, playerRef )
	-- playerRef on kartassa oleva tile, joka käytetään viittauksena (reference). Tästä otetaan ylös
	-- pelaajan haluttu sijainti ja sen jälkeen poistetaan tile kartalta.
	local x, y = playerRef.x, playerRef.y
	display.remove( playerRef )

	-- Luodaan pelaajahahmolle uusi imageSheet, joka sisältää kaikki pelaajan animaatiot:
	local options =
	{
		-- The params below are required
		width = 56,
		height = 56,
		numFrames = 88,
	}
	local imageSheet = graphics.newImageSheet( "Images/hero.png", options )

	local animation = {
		{
			name = "move",
			start = 17,
			count = 8,
			time = 400,
		},

		{
			name = "idle",
			start = 1,
			count = 6,
			time = 400,
		},

		{
			name = "jump",
			start = 25,
			count = 5,
			time = 400,
			loopCount = 1
		},

		{
			name = "climb",
			start = 25,
			count = 5,
			time = 400,
			loopCount = 1
		},
	}

	-- Tehdään sprite objekti ja liitetään se display grouppiin.
	local newPlayer = display.newSprite( imageSheet, animation )
	parent:insert( newPlayer )

	-- Laitetaan "move" animaatiao aktiiviseksi, mutta ei käynnistetä sitä vielä.
	newPlayer:setSequence( "idle" )
	newPlayer:play("idle")

	-- Lisätään pelaajahahmoon erilaisia tietoja, joita tarvitaan myöhemmin pelissä.
	newPlayer.anchorX, newPlayer.anchorY = 0.5,0.5
	newPlayer.x, newPlayer.y = x, y
	newPlayer.tileType = "player"
	newPlayer.hp = gamedata.playerHp or 2
	newPlayer.ropesTouched = 0
	newPlayer.jumpCount = 0
	newPlayer.maxJumpCount = 1
	newPlayer.id = "player"
	newPlayer.moveSpeed = gamedata.moveSpeed or 100

	physics.addBody( newPlayer, "dynamic", { radius = 10, Density = 1, bounce = 0 } )
	newPlayer.isFixedRotation = true


	-- Palautetaan viittaus pelaajahahmoon, jotta sitä voidaan käsitellä ja muokata myöhemmin.
	return newPlayer
end



return player