return {
	masterVolume = 50,
	musicVolume = 50,
	sfxVolume = 50,
	fullscreen = false,

	-- Mitä asetuksia tai asioita pelaaja saa kun uusi peli alkaa.
	newGame = {
		character = {},
		map = "m1_F",
		-- Kaikki kartalla olevat viholliset. Nämä tallennetaan saven kanssa,
		-- jotta viholliset pystyy palauttamaan peliä ladattaessa.
		enemy = {},
		-- Pelin alussa inventory on tyhjä.
		inventory = {},
		-- Pelaajan varusteita tulevat statsit.
		gear = {},

		-- Pelaajan alussa olevat vimpaimet.
		-- Huom! 1. vimpaimen tulee aina olla melee-ase.
		toolbar = {
			"trustysword",
			"heal",
			"leap",
			"shadowStrike",
		},

	},

	-- controls taulukossa on kaikki pelin kontrollit hiirtä lukuunottamatta:
	controls = {
		up = { "w", "up" },
		down = { "s", "down" },
		left = { "a", "left" },
		right = { "d", "right" },
		ability1 = { "1", "" },
		ability2 = { "2", "" },
		ability3 = { "3", "" },
		ability4 = { "4", "" },
		ability5 = { "5", "" },
		ability6 = { "6", "" },
		interact = { "space", "" },
		menu = { "escape", "" },
		inventory = { "tab", "" },
	},
}