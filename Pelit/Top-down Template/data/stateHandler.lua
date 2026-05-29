local gameState = {}

local defaults = {
    player = nil,
    groupLevel = nil,
    groupUI = nil,
    
    levelTiles = nil,
    -------------------------------------
    -- FirstMapLoaded = false,
    prevMapName = nil,
    -- campfireCrafted = false,
    -- timeMachineLevel = 1,
    -- ladderPlaced = false,
    -- torchLit = false,
    -------------------------------------
    gameover = false,
    
}

local currentState


function gameState.delete( key )
    currentState[key] = nil
end

function gameState.reset()
    currentState = {}
    for k, v in pairs(defaults) do
        currentState[k] = defaults[k]
    end 
end

function gameState.get()
    return currentState
end

function gameState.set( key, value )
    currentState[key] = value
end

gameState.reset()

return gameState