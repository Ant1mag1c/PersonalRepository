local t = {}




local random = math.random
local atan2 = math.atan2
local deg = math.deg
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local max = math.max

function t.getAngle( target1, target2 )
    local result = {}
    result.dy = target2.y - target1.y
    result.dx = target2.x - target1.x
    result.angleInRad = atan2(result.dy, result.dx)
    result.angle = deg(result.angleInRad) -- Rotation arvo
    result.currentDistance = sqrt(result.dx^2 + result.dy^2)

    return result
end



return t