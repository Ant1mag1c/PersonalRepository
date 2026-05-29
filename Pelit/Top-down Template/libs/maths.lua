local M = {}

function M.getAngle(from, to)
  return math.deg(math.atan2(to.y - from.y, to.x - from.x))
end

-- Normalize angle to 0–360 degrees
function M.normalizeAngle(angle)
  angle = angle % 360
  if angle < 0 then angle = angle + 360 end
  return angle
end

-- Smallest signed angle difference (-180..180)
function M.angleDifference(a1, a2)
  local diff = (a2 - a1 + 180) % 360 - 180
  return diff
end

-- Convert an angle (degrees) to a unit vector
function M.angleToVector(angle)
  local rad = math.rad(angle)
  local dx, dy = math.cos(rad), math.sin(rad) 
  return dx, dy
end

-- Return the distance between two points
function M.getDistance(from, to)
  return math.sqrt((to.x - from.x) ^ 2 + (to.y - from.y) ^ 2)
end
       
-- Lighter version of getDistance (no sqrt)
function M.getDistanceSquared(from, to)
  local dx, dy = to.x - from.x, to.y - from.y
  return dx * dx + dy * dy
end

return M