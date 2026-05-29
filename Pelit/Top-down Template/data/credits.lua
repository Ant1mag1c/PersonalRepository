-- Credits configuration and data
-- All values are scaled for 480x320 content area
return {
	-- Configuration section - all scene parameters
	config = {
		-- How many milliseconds for full scroll animation
		scrollSpeed = 20000,

		-- ScrollView configuration
		scrollView = {
			top = 60,
			width = 400,
			height = 210,
			scrollHeight = 800,
			bottomPadding = 50,
			backgroundColor = { 0, 0.8 }
		},

		-- Title configuration
		title = {
			text = "Credits",
			font = native.systemFont,
			fontSize = 20,
			color = { 0 },
			yOffset = 22
		},

		-- Back button configuration
		backButton = {
			label = "Back",
			labelAlign = "left",
			fontSize = 16,
			font = native.systemFont,
			labelColor = { default={ 0.9 }, over={ 1 } },
			fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
            shape = "rect",
            width = 60,
            height = 26,
			xOffset = 5,
			yOffset = 5
		}
	},

	-- Credits entries - each entry has its own styling
	-- Add, remove or modify the credits to suit your team and project.
	entries = {
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
		{ text = "ROSO GAMES 2025", font = native.systemFont, fontSize = 16, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "GAME NAME", font = native.systemFont, fontSize = 20, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "PROGRAMMING", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #3", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "GAME DESIGN", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #3", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #4", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "LEVEL DESIGN", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "ART", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #3", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "STORY", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "MUSIC & AUDIO", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },

		{ text = "GAME PRODUCERS", font = native.systemFont, fontSize = 14, color = { 240/255, 220/255, 0 }, padding = 1 },
		{ text = "Name #1", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "Name #2", font = native.systemFont, fontSize = 12, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
		{ text = "", font = native.systemFont, fontSize = 15, color = { 1, 1, 1 }, padding = 1 },
	}
}