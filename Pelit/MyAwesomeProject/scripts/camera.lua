local camera = {}

local hasStarted = false
local cameraTarget
local cameraGroups

local halfWidth = display.actualContentWidth * 0.5
local halfHeight = display.actualContentHeight * 0.5

-- Kamera päivittyy joka frame. Se pyrkii pitämään kameran keskellä kohdetta, joka on määritelty camera.start funktiossa.
-- Todennäköisesti tämä kohde on pelaajahahmo. Kameralle ei ole asetettu mitään ulkorajoja.
local cameraSmoothness = 0.02 -- Voit säätää tätä tarpeidesi mukaan
local cameraDelay = 100       -- Viive kameran päivitykseen (millisekunteina)

local function update()
    -- Tarkista, onko kohde määritelty
    if not cameraTarget then
        return
    end

    local toX = cameraTarget.x - halfWidth
    local toY = cameraTarget.y - halfHeight

    -- Siirretään jokaista annettua display grouppia annetulla skaalalla. Tämän avulla voidaan luoda esim. parallax efekti.
    for i = 1, #cameraGroups do
        local group = cameraGroups[i][1]
        local scale = cameraGroups[i][2]

        local targetX = -toX * scale
        local targetY = -toY * scale

        -- Smoothaa liikettä vain, jos ryhmä on kameran näkyvyysalueella
        group.x = group.x + (targetX - group.x) * cameraSmoothness
        group.y = group.y + (targetY - group.y) * cameraSmoothness
    end
end

-- Käynnistetään kamera ja kerrotaan sille mitä ryhmiä sen tulee liikuttaa, millä skaalalla ja mitä kohdetta se seuraa.
function camera.start(target, groups)
    -- Varmista ettei kameraa ole jo käynnistetty.
    if not hasStarted then
        hasStarted = true

        cameraTarget = target

        cameraGroups = {}
        for i = 1, #groups do
            cameraGroups[i] = { groups[i][1], groups[i][2] }
        end

        -- Lisää viive kameran päivitykseen
        timer.performWithDelay(cameraDelay, function()
            Runtime:addEventListener("enterFrame", update)
        end)
    end
end

function camera.stop()
    if hasStarted then
        hasStarted = false

        Runtime:removeEventListener("enterFrame", update)
    end
end

function updateCameraTarget()
    -- Tarkista, onko pelaaja liikkunut tarpeeksi
    if player.x - originalPlayerX > 300 then
        cameraTarget = player
    end
end

return camera
