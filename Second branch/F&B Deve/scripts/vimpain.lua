local physics = require("physics")
local vimpainData = require("data.vimpainData")
local collisionData = require( "data.collisionData" )
local controls = require( "scripts.controls" )
local emitter = require( "scripts.emitter" )

local vimpain = {}

local function newProjectile( name, body )
    local data = vimpainData[name]

    if not data then
        print( "ERROR: newProjectile - vimpain \"" .. name .. "\" ei löydy." )
        return
    end

    local imageFile = "assets/images/" .. data.image

    if not imageFile then
        print("WARNING: " .. data .. "not a valid weapon")
    else
        local projectile = imageFile and display.newImageRect( body.parent, imageFile, 28, 12 )
        -- projectile.xScale = data.scale or 2
        -- projectile.yScale = data.scale or 2
        projectile.x, projectile.y = body.x, body.y
        projectile.rotation = body._angle

        projectile.id = body.isPlayer and "playerAttack" or "enemyAttack"

        -- Kun projectile osuu kohteeseen niin ajetaan funktio joka poistaa projectilen ja tekee halutut asiat
        function projectile.onEffect( self, target, phase )
            if phase == "began" then
                if projectile.effect == "damage" then
                    local damageMin, damageMax = projectile.damageMin, projectile.damageMax
                    local damageTaken = math.random( damageMin, damageMax )
                    local impactForce = projectile.impactForce
                    local delay = 300
                    -- TODO: Tuleeko kontrollit palauttavan delayn olla myös taulukossa?

                    --Lasketaan suunta johon target paiskotaan törmäyksen jälkeen
                    local dx = target.x - projectile.x
                    local dy = target.y - projectile.y
                    local lenght = math.sqrt(dx^2 + dy^2)
                    local xDir, yDir = dx / lenght, dy / lenght

                    target.movementDisabled = false
                    target:setLinearVelocity( 0, 0 )
                    target:applyLinearImpulse(xDir * impactForce, yDir * impactForce, target.x, target.y)
                    target.stop( "controls", delay )

                    target:takeHit( damageTaken )

                    local newEmitter = emitter.explosion( projectile.x, projectile.y )
                    body.parent:insert( newEmitter )
                end

                display.remove( projectile )
            end
        end

        -- Kopioidaan  kaikki data vimpainDatasta projectileen itseensä
        for k, v in pairs(data) do
            projectile[k] = v
        end

        local collisionFilter = body.isPlayer and collisionData.playerAttackFilter or collisionData.npcAttackFilter
        physics.addBody(projectile, "static", { filter = collisionFilter, isSensor = true })

        -- Luodaan projectilelle lento suunta ja matka jonka se voi lentää
        local distance = math.sqrt(body._dx^2 + body._dy^2)
        local directionX = body._dx / distance
        local directionY = body._dy / distance

        local toX = projectile.x + directionX * projectile.range
        local toY = projectile.y + directionY * projectile.range

        transition.to(projectile, {time=projectile.travelSpeed, x=toX, y=toY, onComplete = function ()
            display.remove(projectile)
        end})

        return projectile
    end
end


local function meleeAttack( name, body, customOptions )
    local data = vimpainData[name]
    local imageFile = "assets/images/Weapons/" .. data.image
    customOptions = customOptions or {}

    if not imageFile then
        print("WARNING: " .. data .. "not a valid weapon")
    else
        body.holdPosition = true

        local angle = body._angle + (customOptions.angle or 0)

        local weapon = display.newImage( body.parent, imageFile )
        weapon.x = body.x + body.width*0.25 * math.cos( body._angleInRad )
        weapon.y = body.y + body.width*0.25 * math.sin( body._angleInRad )
        weapon.anchorX = 0

        -- Jos pelaaja lyö ylöspäin, eli "taakseen", niin älä näytä sitä pelaaja edessä.
        if angle < -45 and angle > -135 then
            weapon:toBack()
        end

        weapon.id = body.isPlayer and "playerAttack" or "enemyAttack"

        function weapon.onEffect( self, target, phase )
            if phase == "began" then
                local damageMin, damageMax = weapon.damageMin, weapon.damageMax
                local damageTaken = math.random( damageMin, damageMax )

                --Lasketaan suunta johon target paiskotaan törmäyksen jälkeen
                local impactForce = weapon.impactForce
                local dx = target.x - weapon.x
                local dy = target.y - weapon.y
                local lenght = math.sqrt(dx^2 + dy^2)
                local xDir, yDir = dx / lenght, dy / lenght

                -- TODO: Tuleeko kontrollit palauttavan delayn olla myös taulukossa?
                local delay = 300

                target.movementDisabled = false
                target:setLinearVelocity( 0, 0 )
                target:applyLinearImpulse(xDir * impactForce, yDir * impactForce, target.x, target.y)
                target.stop( "controls", delay )

                target:takeHit( damageTaken )
            end
        end

        for key, value in pairs(data) do
            weapon[key] = value
        end

        local collisionFilter = body.isPlayer and collisionData.playerAttackFilter or collisionData.npcAttackFilter

        -- TODO: Vaatii parantelua
        physics.addBody(weapon, "static", {
            isSensor = true,
            filter = collisionFilter,
            -- shape = {-weaponWidth / 2, -weaponHeight / 2, weaponWidth / 2, -weaponHeight / 2, weaponWidth / 2, weaponHeight / 2, -weaponWidth / 2, weaponHeight / 2}
        })

        local arch = (customOptions.stab and 0) or (weapon.arch or 0) + (customOptions.arch or 0 )
        local startAngle, endAngle = ( angle + arch * 0.5 ), ( angle - arch * 0.5 )
        weapon.rotation = startAngle

        -- Luodaan miekalle liike jonka jälkeen poistetaan miekka
        transition.to (weapon, {
            time = weapon.duration,
            rotation = endAngle,
            onComplete = function()
                display.remove(weapon)
                body.holdPosition = false
            end
        } )

    end
end

local function novaSpell(name, body)
    local data = vimpainData[name]

    local xLoc, yLoc
    if name == "frostCircle" then
        xLoc, yLoc = body.x + body._dx, body.y + body._dy
    else
        xLoc, yLoc = body.x, body.y
    end

    local spellFrame = display.newCircle( body.parent, xLoc, yLoc, data.range or 100 )
    -- local newEmitter = emitter.frostCircle( body.parent, xLoc, yLoc )
    local newEmitter = emitter[name]( xLoc, yLoc )
    body.parent:insert( newEmitter )

    spellFrame:setFillColor(1,0,0)
    spellFrame.alpha = 0

    local collisionFilter = body.isPlayer and collisionData.playerAttackFilter or collisionData.npcAttackFilter
    physics.addBody(spellFrame, "static", { radius=spellFrame.width*0.5, filter = collisionFilter, isSensor = true })

    -- Kopioidaan  kaikki data vimpainDatasta projectileen itseensä
    for k, v in pairs(data) do
        spellFrame[k] = v
    end

    -- Kesto lasketaan sen mukaan montako kertaa efekti "tickaa" ja montako kuinka pitkä väli tickien välillä on.
    local tickCount = data.tickCount or 5
    local tickRate = data.tickRate or 600

    -- Lista kohteista, jotka ovat vimpaimen vaikutusalueella.
    local hitList = {}

    function spellFrame.onEffect( self, target, phase )
        if phase == "began" then
            -- Lisää kohde listaan, ellei se jo ole.
            local duplicate = false

            for i = 1, #hitList do
                if target == hitList[i] then
                    duplicate = true
                    break
                end
            end

            if not duplicate then
                hitList[#hitList+1] = target
            end

        elseif phase == "ended" then
            -- Poista kohde listalta, jos se löytyy sieltä.
            for i = 1, #hitList do
                if target == hitList[i] then
                    table.remove( hitList, i )
                    break
                end
            end

        end
    end

    timer.performWithDelay( tickRate, function( event )
        for i = 1, #hitList do
            local target = hitList[i]

            local damageTaken = math.random( spellFrame.damageMin, spellFrame.damageMax )

            --Lasketaan suunta johon target paiskotaan törmäyksen jälkeen
            local impactForce = spellFrame.impactForce
            local dx = target.x - spellFrame.x
            local dy = target.y - spellFrame.y
            local lenght = math.sqrt(dx^2 + dy^2)
            local xDir, yDir = dx / lenght, dy / lenght


            -- target.movementDisabled = false
            target:setLinearVelocity( 0, 0 )
            target:applyLinearImpulse(xDir * impactForce, yDir * impactForce, target.x, target.y)
            target.stop( "controls", 1 )

            target:takeHit( damageTaken )
        end

        -- Viimeinen tick, eli poista efekti.
        if event.count == tickCount then
            display.remove( spellFrame )
            if newEmitter.timer then
                timer.cancel(newEmitter.timer)
                newEmitter.timer = nil
                display.remove( newEmitter )
            end
        end

    end, tickCount )

    return spellFrame
end

---------------------------------------------------------------------------------------------------------
-- Muut Funktiot
---------------------------------------------------------------------------------------------------------

function vimpain.dodge( target, customOptions )
    local data = vimpainData["dodge"]
    customOptions = customOptions or {}
    local range = customOptions.range or data.range

    local rad = target._angleInRad
    local xDir, yDir = math.cos(rad), math.sin(rad)
    local delay = data.duration
    -- Estetään pelaajan liike dodgen ajaksi ja työnnetään pelaaja haluttuun suuntaan
    target.movementDisabled = false
    target:setLinearVelocity( 0, 0 )
    target:applyLinearImpulse( xDir * range, yDir * range, target.x, target.y )
    target.stop( "controls", delay )

    return delay
end

function vimpain.heal(body)
    local data = vimpainData["heal"]
    local maxHealth = body.maxHealth or 50
    local currHealth = body.health
    local count = 0
    local maxCount = data.effect

    if currHealth < maxHealth then
        repeat
            currHealth = currHealth + 1
            count = count + 1
        until currHealth == maxHealth or count == maxCount
        body.health = currHealth
    end

    local newEmitter = emitter.heal( body.sprite.x, body.sprite.y )
    body:insert( newEmitter )
end

---------------------------------------------------------------------------------------------------------
-- Erilliset, kustomoidut vimpaimet.
---------------------------------------------------------------------------------------------------------

function vimpain.frostCircle( body )
   local newNova = novaSpell("frostCircle", body)
   return newNova
end

function vimpain.flurry( body )
    local data = vimpainData["flurry"]

    timer.performWithDelay( data.hitDelay, function ()
        local weapon = meleeAttack( body.weapon, body, {angle=math.random( -data.angleVariance, data.angleVariance )}  )
    end, data.hitCount )
end


function vimpain.spin( body )
    local data = vimpainData["spin"]

    local weapon = meleeAttack( body.weapon, body, {arch=data.arch} )
    return weapon
end

function vimpain.leap( body )
    body.isSensor = true
    local delay = vimpain.dodge( body, {range=11} )

    local jumpHeight = 20
    local scaleTo = 1.1

    transition.to( body.sprite, { time=delay*0.5, xScale=scaleTo, yScale=scaleTo, y=body.sprite.y - jumpHeight, onComplete=function()
        transition.to( body.sprite, { time=delay*0.5, xScale=1, yScale=1, y=body.sprite.y + jumpHeight })
    end })

    timer.performWithDelay(delay+20, function ()
        timer.performWithDelay(1, function ()
            body.isSensor = false
        end)
        local leap = novaSpell( "leap", body )
    end)
end

function vimpain.shadowStrike( body, isStabSeguence )
    local data = vimpainData["shadowStrike"]
    body.alpha = 0.5
    body.isVisible = false
    -- Savu sprite

    if isStabSeguence and body.stealthTimer then
        body.alpha = 1
        body.isVisible = true

        if body.stealthTimer then
            timer.cancel(body.stealthTimer)
            body.stealthTimer = nil
        end

        local weapon = meleeAttack( body.weapon, body, {stab = true} )
        return
    end
    print( isStabSeguence )

    body.stealthTimer = timer.performWithDelay( data.duration or 1000, function()
        if not body.isVisible then
            body.alpha = 1
            body.isVisible = true
            body.stealthTimer = nil
        end

    end )
end
---------------------------------------------------------------------------------------------------------

-- Automatisoi kaikkien melee ja ranged hyökkäysfunktioiden luonti:
for _vimpainName, _vimpainData in pairs( vimpainData ) do
    if _vimpainData.type and _vimpainData.type == "weapon" then

        vimpain[_vimpainName] = function( body )
            local weapon = meleeAttack( body.weapon, body )

            -- TODO: lisää mahdollisia vimpainkohtaisia ominaisuuksia ehtolausekkeilla.

            return weapon
        end

    elseif _vimpainData.attackType and _vimpainData.attackType == "projectile" then

        vimpain[_vimpainName] = function( body )
            local projectile = newProjectile( _vimpainName, body )

            -- TODO: lisää mahdollisia vimpainkohtaisia ominaisuuksia ehtolausekkeilla.

            return projectile
        end

    end
end

---------------------------------------------------------------------------------------------------------
local function fade(object)

end


return vimpain
