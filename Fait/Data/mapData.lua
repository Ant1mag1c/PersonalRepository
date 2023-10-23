return {

	-- Event debuggaus:
    {
        colWidth = 300,
        doublePathChance =  0.35,
        maxDoubleLevels = 2,
        pathCount = 1,
        stepHeight = 120,
        stepCount = 3,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        nodeContents = {
            elite = { minCount=1, maxCount=1, maxPerPath=2, firstStep=2, lastStep=3 },
            sauna = { minCount=1, maxCount=1, maxPerPath=1, firstStep=2, lastStep=3 },
            treasure = { minCount=1, maxCount=1, maxPerPath=1, firstStep=2, lastStep=3 },
            store = { minCount=1, maxCount=1, maxPerPath=1, firstStep=2, lastStep=3 },
            randomEvent = { minCount=8, maxCount=9, maxPerPath=3, firstStep=1, lastStep=3 },
        }
    },

	{
        colWidth = 300,
        doublePathChance =  0.35,
        maxDoubleLevels = 2,
        pathCount = 2,
        stepHeight = 120,
        stepCount = 5,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        nodeContents = {
            elite = { minCount=1, maxCount=2, maxPerPath=1, firstStep=2, lastStep=4 },
            sauna = { minCount=4, maxCount=4, maxPerPath=4, firstStep=5, lastStep=5 },
            treasure = { minCount=1, maxCount=1, maxPerPath=1, firstStep=2, lastStep=4 },
            store = { minCount=0, maxCount=0, maxPerPath=1, firstStep=1, lastStep=3 },
            randomEvent = { minCount=2, maxCount=4, maxPerPath=1, firstStep=2, lastStep=4 },
        }
    },

    {
        colWidth = 300,
        doublePathChance =  0.2,
        maxDoubleLevels = 2,
        pathCount = 3,
        stepHeight = 120,
        stepCount = 6,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        nodeContents = {
            elite = { minCount=3, maxCount=6, maxPerPath=2, firstStep=1, lastStep=5 },
            sauna = { minCount=4, maxCount=6, maxPerPath=2, firstStep=1, lastStep=6 },
            treasure = { minCount=3, maxCount=5, maxPerPath=2, firstStep=1, lastStep=6 },
            store = { minCount=2, maxCount=3, maxPerPath=1, firstStep=1, lastStep=5 },
            randomEvent = { minCount=4, maxCount=8, maxPerPath=3, firstStep=1, lastStep=5 },
        }
    },

    {
        colWidth = 300,
        doublePathChance =  0.45,
        maxDoubleLevels = 2,
        pathCount = 3,
        stepHeight = 120,
        stepCount = 8,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        nodeContents = {
            elite = { minCount=6, maxCount=10, maxPerPath=2, firstStep=1, lastStep=7 },
            sauna = { minCount=4, maxCount=7, maxPerPath=2, firstStep=1, lastStep=8 },
            treasure = { minCount=3, maxCount=6, maxPerPath=2, firstStep=1, lastStep=8 },
            store = { minCount=2, maxCount=5, maxPerPath=2, firstStep=1, lastStep=8 },
            randomEvent = { minCount=6, maxCount=10, maxPerPath=3, firstStep=1, lastStep=8 },
        }
    },

}