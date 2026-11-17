local playTime = 400

return {

    -- Character animations
	----------------------------------------------------------------------------------
    sequences = {
        player = {
            { name = "idle",   start = 1,  count = 1, time = playTime*0.8, loopCount = 0 },
            { name = "attack", start = 28, count = 6, time = playTime*1.5, loopCount = 1 },
            { name = "jump", start = 23, count = 1, time = playTime, loopCount = 1 },
            { name = "move",   start = 2,  count = 8, time = playTime, loopCount = 0 },
            { name = "climb",   start = 10,  count = 6, time = playTime*1.2, loopCount = 0 },
            { name = "climbIdle",   start = 12,  count = 1, time = playTime, loopCount = 0 },
        },

        enemy = {
            { name = "idle",   start = 1,  count = 1, time = playTime*0.8, loopCount = 0 },
            { name = "move",   start = 2,  count = 8, time = playTime, loopCount = 0 },
            { name = "cast", start = 10, count = 6, time = playTime, loopCount = 1 },
        }
    },

    sheets = {
        enemy = "assets/images/characters/wizard.png",
        player = "assets/images/characters/player.png"
    },

    data = {
        player = {
            width = 64,
            height = 64,
            numFrames = 36
        },

        enemy = {
            width = 64,
            height = 64,
            numFrames = 27
        },
    }



}