local effects = require("data.effects")

local M = {}

local effectTimer = nil

function M.new(group, x, y, effectName)
    local params = effects[effectName]

    if not params then return nil end

    local emitter = display.newEmitter(params)
    group:insert(emitter)
    emitter.x, emitter.y = x, y
    emitter.id = effectName
    return emitter
end

return M
