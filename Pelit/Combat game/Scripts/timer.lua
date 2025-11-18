-- Timer Management Utility
local Timer = {}
local timers = {}
local nextId = 0

-- Create a unique id for each timer
local function newId()
    nextId = nextId + 1
    return nextId
end

-------------------------------------------------
-- Run a function once after X milliseconds
-------------------------------------------------
function Timer.after(delay, fn, tag)
    local id = newId()

    timers[id] = timer.performWithDelay(delay, function()
        timers[id] = nil        -- auto cleanup
        if fn then fn() end
    end)

    timers[id].tag = tag
    return id
end

-------------------------------------------------
-- Run a function repeatedly
-- returns the timer ID
-------------------------------------------------
function Timer.every(delay, fn, iterations, tag)
    local id = newId()

    timers[id] = timer.performWithDelay(delay, fn, iterations or 0)
    timers[id].tag = tag

    return id
end

-------------------------------------------------
-- Cancel a specific timer
-------------------------------------------------
function Timer.cancel(id)
    local t = timers[id]
    if t then
        timer.cancel(t)
        timers[id] = nil
    end
end

-------------------------------------------------
-- Cancel all timers
-------------------------------------------------
function Timer.cancelAll()
    for id, t in pairs(timers) do
        timer.cancel(t)
    end
    timers = {}
end

-------------------------------------------------
-- Cancel all timers with a tag
-------------------------------------------------
function Timer.cancelTag(tag)
    for id, t in pairs(timers) do
        if t.tag == tag then
            timer.cancel(t)
            timers[id] = nil
        end
    end
end

return Timer