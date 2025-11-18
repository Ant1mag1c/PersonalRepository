--------------------------------------------------------------------------------
-- SUPPORTIVE FUNCTIONS MODULE
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- ANGLE AND DISTANCE
--------------------------------------------------------------------------------

-- Return the angle between two points in degrees
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
  return { x = math.cos(rad), y = math.sin(rad) }
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

--------------------------------------------------------------------------------
-- LINEAR INTERPOLATION (LERP)
--------------------------------------------------------------------------------

function M.lerp(a, b, t)
  return a + (b - a) * t
end

function M.lerpPoint(p1, p2, t)
  return {
    x = p1.x + (p2.x - p1.x) * t,
    y = p1.y + (p2.y - p1.y) * t
  }
end

function M.smoothLerp(a, b, t)
  t = t * t * (3 - 2 * t)
  return a + (b - a) * t
end

--------------------------------------------------------------------------------
-- GEOMETRY / VECTOR HELPERS
--------------------------------------------------------------------------------

function M.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

function M.vectorLength(v)
  return math.sqrt(v.x * v.x + v.y * v.y)
end

function M.normalizeVector(v)
  local len = M.vectorLength(v)
  if len == 0 then return { x = 0, y = 0 } end
  return { x = v.x / len, y = v.y / len }
end

function M.moveInDirection(what, angle, speed)
  local rad = math.rad(angle)
  what.x = what.x + math.cos(rad) * speed
  what.y = what.y + math.sin(rad) * speed
end

function M.approach(current, target, step)
  if current < target then
    return math.min(current + step, target)
  else
    return math.max(current - step, target)
  end
end

function M.moveTowards(what, where, speed)
  local angle = math.atan2(where.y - what.y, where.x - what.x)
  what.x = what.x + math.cos(angle) * (speed or 5)
  what.y = what.y + math.sin(angle) * (speed or 5)
end

--------------------------------------------------------------------------------
-- RANDOM / NOISE HELPERS
--------------------------------------------------------------------------------

function M.randomFloat(min, max)
  return min + math.random() * (max - min)
end

function M.randomPointInCircle(radius)
  local angle = math.random() * math.pi * 2
  local r = math.sqrt(math.random()) * radius
  return { x = math.cos(angle) * r, y = math.sin(angle) * r }
end

--------------------------------------------------------------------------------
-- TABLE UTILITIES
--------------------------------------------------------------------------------

function M.deepCopy(orig)
  local copy = {}
  for k, v in pairs(orig) do
    if type(v) == "table" then
      copy[k] = M.deepCopy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

--------------------------------------------------------------------------------
-- DEBUG HELPERS
--------------------------------------------------------------------------------

function M.printPoint(label, p)
  print(label .. ": (" .. string.format("%.2f", p.x) .. ", " .. string.format("%.2f", p.y) .. ")")
end

--------------------------------------------------------------------------------
-- MODULE RETURN
--------------------------------------------------------------------------------

return M
