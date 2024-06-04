local emitterData = require( "data.emitterData" )
local emitter = {}

function emitter.new( name, xPos, yPos )
    local data = emitterData[name]
    local newEmitter = display.newEmitter( data )
    newEmitter.x, newEmitter.y = xPos, yPos

    newEmitter.timer = timer.performWithDelay( 2000, function()
        if newEmitter then
            newEmitter.timer = nil
            display.remove( newEmitter )
            -- print("Emitter destoyed!")
        end
    end )

    return newEmitter
end

---------------------------------------------------------------------------------------------------------
-- Vimpain funktiot
---------------------------------------------------------------------------------------------------------

function emitter.explosion( xPos, yPos )
    local newEmitter = emitter.new( "fireballExplosion", xPos, yPos )
    return newEmitter
end

function emitter.frostCircle( xPos, yPos )
    local newEmitter = emitter.new( "frostCircle", xPos, yPos )
    return newEmitter
end

function emitter.leap( xPos, yPos )
    local newEmitter = emitter.new( "leap", xPos, yPos )
    return newEmitter
end

function emitter.heal( xPos, yPos )
    local newEmitter = emitter.new( "heal", xPos, yPos )
    return newEmitter
end


return emitter