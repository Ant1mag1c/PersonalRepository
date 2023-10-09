return {

    {
        colWidth = 300,
        doublePathChance =  0.35,
        maxDoubleLevels = 2,
        pathCount = 4,
        stepHeight = 120,
        stepCount = 6,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        storeFirstSpawnStep = 1,
        eventFirstSpawnStep = 1,
        nodeContents = {
            elite = { minCount=1, maxCount=1, maxPerPath=2, firstStep=1, lastStep=3 },
            sauna = { minCount=0, maxCount=0, maxPerPath=1, firstStep=1, lastStep=3 },
            treasure = { minCount=0, maxCount=0, maxPerPath=0, firstStep=0, lastStep=0 },
            store = { minCount=1, maxCount=1, maxPerPath=1, firstStep=1, lastStep=3 },
            randomEvent = { minCount=8, maxCount=9, maxPerPath=3, firstStep=1, lastStep=3 },
        }
    },

    {
        colWidth = 300,
        doublePathChance =  0.35,
        maxDoubleLevels = 2,
        pathCount = 2,
        stepHeight = 120,
        stepCount = 3,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        storeFirstSpawnStep = 3,
        eventFirstSpawnStep = 2,
        nodeContents = {
            elite = { minCount=3, maxCount=6, maxPerPath=2, firstStep=1, lastStep=3 },
            sauna = { minCount=2, maxCount=3, maxPerPath=1, firstStep=1, lastStep=3 },
            treasure = { minCount=3, maxCount=5, maxPerPath=2, firstStep=1, lastStep=3 },
            store = { minCount=2, maxCount=3, maxPerPath=1, firstStep=1, lastStep=3 },
            randomEvent = { minCount=4, maxCount=8, maxPerPath=3, firstStep=1, lastStep=3 },
        }
    },

    {
        colWidth = 300,
        doublePathChance =  0.35,
        maxDoubleLevels = 2,
        pathCount = 3,
        stepHeight = 120,
        stepCount = 5,
        levelWidth = 40,
        levelHeight = 40,
        levelPad = 10,
        nodesPerForest = 6,
        stepsPerWater = 3,
        storeFirstSpawnStep = 3,
        eventFirstSpawnStep = 2,
        nodeContents = {
            elite = { minCount=3, maxCount=6, maxPerPath=2, firstStep=1, lastStep=3 },
            sauna = { minCount=2, maxCount=3, maxPerPath=1, firstStep=1, lastStep=3 },
            treasure = { minCount=3, maxCount=5, maxPerPath=2, firstStep=1, lastStep=3 },
            store = { minCount=2, maxCount=3, maxPerPath=1, firstStep=1, lastStep=3 },
            randomEvent = { minCount=4, maxCount=8, maxPerPath=3, firstStep=1, lastStep=3 },
        }
    }

}