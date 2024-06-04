-- Luodaan mukavuus/yksinkertaistus funktiot, joilla pelaajan ja vihollisten sprite sheetit
-- saadaan nopeasti ja helposti kopioitua yhdestä lähteestä pienillä muutoksilla.
local function prepareEnemySheet( params )
	local timeWalk = 500

	return {
		image = params.filename,

		sheetOptions = {
			width = params.size,
			height = params.size,
			numFrames = 12
		},

		animSequences = {
			{
				name = "walkDown",
				start = 4,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkUp",
				start = 10,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkLeft",
				start = 1,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkRight",
				start = 7,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
		}
	}
end


local function preparePlayerSheet( filename )
	local timeWalk = 500
	local timeIdle = 750
	local timeAttack = 750
	local timeDeath = 1200

	return {
		image = filename,

		sheetOptions = {
			width = 34,
			height = 34,
			numFrames = 63
		},

		animSequences = {
			{
				name = "walkDown",
				start = 19,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkUp",
				start = 37,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkLeft",
				start = 10,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},
			{
				name = "walkRight",
				start = 28,
				count = 3,
				time = timeWalk,
				loopCount = 0
			},

			-----------------------

			{
				name = "idleDown",
				start = 23,
				count = 3,
				time = timeIdle,
				loopCount = 0
			},
			{
				name = "idleUp",
				start = 40,
				count = 3,
				time = timeIdle,
				loopCount = 0
			},
			{
				name = "idleLeft",
				start = 14,
				count = 3,
				time = timeIdle,
				loopCount = 0
			},
			{
				name = "idleRight",
				start = 31,
				count = 3,
				time = timeIdle,
				loopCount = 0
			},

			-----------------------

			{
				name = "attackDown",
				start = 26,
				count = 3,
				time = timeAttack,
				loopCount = 0
			},
			{
				name = "attackUp",
				start = 43,
				count = 3,
				time = timeAttack,
				loopCount = 0
			},
			{
				name = "attackLeft",
				start = 17,
				count = 3,
				time = timeAttack,
				loopCount = 0
			},
			{
				name = "attackRight",
				start = 34,
				count = 3,
				time = timeAttack,
				loopCount = 0
			},

			-----------------------

			{
				name = "death",
				start = 31,
				count = 3,
				time = timeDeath,
				loopCount = 0
			},
		}
	}
end


return {

	shroomRed = {

		stats = {
			strength = 0,
			agility = 0,
			intellect = 0,
			health = 10,
			movementSpeed = 250,
			armorSpell = 0,
			armorPhysical = 0,
			attackRange = 150,
			weapon = "miekka",
			radius = 14,
		},

		sheet = prepareEnemySheet( {filename="assets/images/Enemies/ShroomRedSprites1.png", size=32 } ),
	},


	shroomWhite = {

		stats = {
			strength = 0,
			agility = 0,
			intellect = 0,
			health = 10,
			movementSpeed = 250,
			armorSpell = 0,
			armorPhysical = 0,
			attackRange = 200,
			weapon = "fireball",
			radius = 14,
		},

		sheet = prepareEnemySheet( {filename="assets/images/Enemies/ShroomWhiteSprites1.png", size=32 } ),
	},


	cultist = {

		stats = {
			strength = 0,
			agility = 0,
			intellect = 0,
			health = 25,
			movementSpeed = 350,
			armorSpell = 0,
			armorPhysical = 0,
			attackRange = 250,
			weapon = "miekka",
			radius = 14,
		},

		sheet = prepareEnemySheet( {filename="assets/images/Enemies/cultist.png", size=34 } ),
	},


	apple = {

		stats = {
			strength = 0,
			agility = 0,
			intellect = 0,
			health = 50,
			movementSpeed = 200,
			armorSpell = 0,
			armorPhysical = 0,
			attackRange = 100,
			weapon = "miekka",
			radius = 28,
		},

		sheet = prepareEnemySheet( {filename="assets/images/Enemies/appleMovement.png", size=64 } ),
	},


	potato = {

		stats = {
			strength = 0,
			agility = 0,
			intellect = 0,
			health = 100,
			movementSpeed = 150,
			armorSpell = 5,
			armorPhysical = 5,
			attackRange = 100,
			weapon = "miekka",
			radius = 30,
		},

		sheet = prepareEnemySheet( {filename="assets/images/Enemies/potatoMovement.png", size=64 } ),
	},


	--------------------------------------------------------------------------------------------


	mustikka = {
		info = {
			name = "Mustikka",
			description = "Mustikka on mustikka. Mustikka on mustikka. Mustikka on mustikka. Mustikka on mustikka.",
			isPlayer = true,
		},

		stats = {
			strength = 1,
			agility = 2,
			intellect = 1,
			health = 50,
			movementSpeed = 500,
			armorSpell = 0,
			armorPhysical = 0,
			radius = 14,
		},

		sheet = preparePlayerSheet( "assets/images/PlayerCharacters/blueberry.png" ),
	},


	vadelma = {
		info = {
			name = "Vadelma",
			description = "Vadelma on vadelma.",
			isPlayer = true,
		},

		stats = {
			strength = 2,
			agility = 1,
			intellect = 1,
			health = 50,
			movementSpeed = 500,
			armorSpell = 0,
			armorPhysical = 0,
			radius = 14,
		},

		sheet = preparePlayerSheet( "assets/images/PlayerCharacters/raspberry.png" ),
	},


	tyrni = {
		info = {
			name = "Tyrni",
			description = "Tyrni on tyrni.",
			isPlayer = true,
		},

		stats = {
			strength = 1,
			agility = 1,
			intellect = 2,
			health = 50,
			movementSpeed = 500,
			armorSpell = 0,
			armorPhysical = 0,
			radius = 14,
		},

		sheet = preparePlayerSheet( "assets/images/PlayerCharacters/seaberry.png" ),
	},


	--------------------------------------------------------------------------------------------
}