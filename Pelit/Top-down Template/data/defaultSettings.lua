return {
	-- audio settings
	audio = {
		-- NB! volume and channels' names must match.
		volume = {
			master = 50, -- master volume affects all channels
			music = 50,
			sfx = 50,
			-- ambient = 50,
			-- voice = 50,
		},
		channels = {
			music = { from = 1, to = 1 },
			sfx = { from = 2, to = 32 },
			-- ambient = { from = 11, to = 13 },
			-- voice = { from = 14, to = 16 },
		}
	},

	-- display settings
	fullscreen = true,

	-- controls
	controls = {
		["left"] = { "a" },
		["right"] = { "d" },
		["up"] = { "w" },
		["down"] = { "s" },
		["attackRight"] = { "right" },
		["attackLeft"] = { "left" },
		["attackUp"] = { "up" },
		["attackDown"] = { "down" },
		["interact"] = { "space", "e" },
		["inventory"] = { "i", "tab" },
		["menu"] = { "escape" },
	},
}