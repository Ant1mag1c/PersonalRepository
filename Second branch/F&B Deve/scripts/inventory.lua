_G.inventorySlots = {}

local toolbar

local screen = require( "scripts.screen" )
local vimpainData = require( "data.vimpainData" )
local loadsave = require( "scripts.loadsave" )


local rowCount = 4
local columnCount = 4
local inventorySlotCount = rowCount * columnCount
for i = 1, inventorySlotCount + 2 do
    if not loadsave.gamedata.inventory[i] then
        loadsave.gamedata.inventory[i] = "nil"
    end
end

local inventory = {}
inventory.isOpen = false

local tooltip
local tooltipTimer

local invSlotFrom = nil
local group
local deleteBox
local heading
local stats

local mouse = {}

local imageOptions = {
    width = 80,
    height = 80,
    paddingHorizontal = 10,
    paddingVertical = 10
}

local function showTooltip(errorType, vimpainType)

    if tooltipTimer then
        timer.cancel(tooltipTimer)
        tooltipTimer = nil
        display.remove(tooltip)
    end

    tooltip = display.newGroup()

    local background = display.newRect(tooltip, screen.centerX, screen.centerY, 500, 200)
    background:setFillColor(0.1, 0.8)

    local text
    if errorType == "restricted" then
        -- Jos kyseessä on "weapon" vimpain, niin täsmennetään sen kohdalla erikseen "melee weapon",
        -- sillä pelissä on jousia yms. ranged aseita, joiden siirrosta seuraava error viesti olisi epäselvä.
        vimpainType = vimpainType == "weapon" and "melee weapon" or vimpainType
        text = "You can only place " .. vimpainType .. "s here"
    elseif errorType == "empty" then
        text = "You must always have " .. vimpainType .. " equipped"
    elseif errorType == "notToolbar" then
        text = "You can't place " .. vimpainType .. "s here"
    elseif errorType == "unequip" then
        text = "You must unequip this vimpain before you can destroy it."
    end

    local warning = display.newText({
        parent = tooltip,
        text = text,
        x = background.x,
        y = background.y,
        width = background.width - 20,
        font = native.systemFont,
        fontSize = 22,
        align = "center"
    })

    tooltipTimer = timer.performWithDelay(1500, function()
        tooltipTimer = nil
        display.remove(tooltip)
    end)

end


local function updateStats()
    display.remove( stats )

    local player = loadsave.gamedata.character
    local gear = player.gear
    -- table.print( gear )

    -- Nollataan pelaajan vimpaimista saamat statsit ja päivitetään ne uudestaan sen jälkeen.
    for k, _ in pairs( gear ) do
        gear[k] = 0
    end

    local function addGear( vimpainName )
        local data = vimpainData[vimpainName]

        -- Jos armor tai trinket slotissa on vimpain, niin lisää kaikki siinä löytyvät
        -- arvot pelaajan gear statseihin, jos ne arvot löytyvät molemmista taulukoista.
        if data then
            for k, _ in pairs( gear ) do
                if data[k] then
                    gear[k] = gear[k] + data[k]
                end
            end
        end
    end
    addGear( loadsave.gamedata.inventory[#loadsave.gamedata.inventory-1] )
    addGear( loadsave.gamedata.inventory[#loadsave.gamedata.inventory] )
    -- table.print( gear )


    player.healthCurrent = player.healthCurrent or player.health or 50

    -- Luodaan pitkä tekstihirviö, jossa on kaikki pelaajan statsit. Riippuen pelaajan käytössä olevista vimpaimista,
    -- pelaajahahmon statsit voivat nousta tai laskea. Nämä indikoidaan pelaajalle "+" ja "-" symboleilla rivien lopussa.
    local text = "Character: " .. player.name ..
        "\nHealth: " .. player.healthCurrent .. "/" .. (player.health + gear.health) .. (gear.health > 0 and "+" or gear.health < 0 and "-" or "") ..
        "\nSpeed: " .. (player.movementSpeed + gear.movementSpeed) .. (gear.movementSpeed > 0 and "+" or gear.movementSpeed < 0 and "-" or "") ..
        "\nIntellect: " .. (player.intellect + gear.intellect) .. (gear.intellect > 0 and "+" or gear.intellect < 0 and "-" or "") ..
        "\nStrength: " .. (player.strength + gear.strength) .. (gear.strength > 0 and "+" or gear.strength < 0 and "-" or "") ..
        "\nAgility: " .. (player.agility + gear.agility) .. (gear.agility > 0 and "+" or gear.agility < 0 and "-" or "") ..
        "\nPhysical armor: " .. (player.armorPhysical + gear.armorPhysical) .. (gear.armorPhysical > 0 and "+" or gear.armorPhysical < 0 and "-" or "") ..
        "\nSpell armor: " .. (player.armorSpell + gear.armorSpell) .. (gear.armorSpell > 0 and "+" or gear.armorSpell < 0 and "-" or "")


    stats = display.newText({
        parent = group,
        text = text,
        x = heading.x - heading.width*0.5,
        y = heading.y + heading.height + 14,
        -- width = 210,
        font = native.systemFont,
        fontSize = 20,
        align = "left",
    })
    stats.anchorX, stats.anchorY = 0, 0
end


-- Tarkastetaan onko hiiri jonkun inventory slotin päällä.
local function mousePositionCheck()
    if invSlotFrom then

        -- Luodaan väliaikainen taulukko t, johon lisätään viittaukset inventory ja toolbar slotteihin.
        -- Tämän avulla voidaan hallita molempia taulukoita kerralla.
        local t = {}

        for i = 1, #_G.inventorySlots do
            t[i] = _G.inventorySlots[i]
        end

        for i = 1, #_G.toolbarSlots do
            t[#t+1] = _G.toolbarSlots[i]
        end

        for i = 1, #t do

            local bounds = t[i].contentBounds

            if bounds.xMin < mouse.x and mouse.x < bounds.xMax and bounds.yMin < mouse.y and mouse.y < bounds.yMax then
                -- print("slot", t[i].type, invSlotFrom.type)
                -- print("vimpain", t[i].item and t[i].item.type, invSlotFrom.item and invSlotFrom.item.type)

                local move = false
                local errorType, errorVimpain

                local toSlotType = t[i].type
                local fromVimpainType = invSlotFrom.item.type

                if toSlotType then
                    if toSlotType == fromVimpainType then
                        move = true
                    end

                    errorType = "restricted"
                    errorVimpain = toSlotType
                else
                    local toVimpainType = t[i].item and t[i].item.type
                    local fromSlotType = invSlotFrom.type

                    if fromSlotType then
                        if toVimpainType == fromSlotType then
                            move = true
                        end
                        errorType = "empty"
                    else
                        if t[i].src ~= "toolbar" or not (fromVimpainType == "weapon" or fromVimpainType == "armor" or fromVimpainType == "trinket") then
                            move = true
                        end
                        errorType = "notToolbar"
                    end
                    errorVimpain = fromVimpainType
                end

                if not move then
                    showTooltip(errorType, errorVimpain)
                    invSlotFrom.item.x, invSlotFrom.item.y = invSlotFrom.x, invSlotFrom.y
                    return
                end

                t[i].item, invSlotFrom.item = invSlotFrom.item, t[i].item
                t[i].item.x, t[i].item.y = t[i].x, t[i].y
                -- print(t[i].src, t[i].id, t[i].type, invSlotFrom.src, invSlotFrom.id, invSlotFrom.type)

                local parent, slots
                if t[i].src == "inventory" then
                    parent, slots = group, _G.inventorySlots
                else
                    parent, slots = toolbar.groupRef, _G.toolbarSlots
                end

                -- Vaihdetaan inventoryn/toolbarin vimpainten nimiä taulukoissa.
                local tableTo = t[i].src == "inventory" and loadsave.gamedata.inventory or loadsave.gamedata.toolbar
                local tableFrom = invSlotFrom.src == "inventory" and loadsave.gamedata.inventory or loadsave.gamedata.toolbar
                tableTo[t[i].id], tableFrom[invSlotFrom.id] = tableFrom[invSlotFrom.id], tableTo[t[i].id]

                if t[i].src ~= invSlotFrom.src then
                    display.remove( t[i].item )
                    display.remove( invSlotFrom.item )

                    inventory.newVimpain( t[i].item.name, t[i].id, parent, slots )

                    if invSlotFrom.item then
                        local parent, slots
                        if invSlotFrom.src == "inventory" then
                            parent, slots = group, _G.inventorySlots
                        else
                            parent, slots = toolbar.groupRef, _G.toolbarSlots
                        end

                        inventory.newVimpain( invSlotFrom.item.name, invSlotFrom.id, parent, slots )

                    end

                else
                    if invSlotFrom.item then
                        invSlotFrom.item.x, invSlotFrom.item.y = invSlotFrom.x, invSlotFrom.y
                    end
                end

                -- Pelaaja siirsi onnistuneesti uuden vimpaimen armor tai trinket slottiin, eli päivitetään pelaajan gear statsit.
                if t[i].type == "armor" or t[i].type == "trinket" then
                    updateStats()
                end

                return
            end
        end

        -- Tarkistetaan tiputtiko pelaaja vimpaimen "delete box:iin".
        local bounds = deleteBox.contentBounds
        if bounds.xMin < mouse.x and mouse.x < bounds.xMax and bounds.yMin < mouse.y and mouse.y < bounds.yMax then
            -- Estä pelaajaa poistamasta vimpaimia suoraan rajoitetuista sloteista.
            if invSlotFrom.type then
                showTooltip( "unequip" )
                invSlotFrom.item.x, invSlotFrom.item.y = invSlotFrom.x, invSlotFrom.y
                return
            end

            -- Poista vimpain ja tyhjennä se inventorystä/toolbarista.
            display.remove( invSlotFrom.item )
            invSlotFrom.item = nil

            if invSlotFrom.src == "inventory" then
                loadsave.gamedata.inventory[invSlotFrom.id] = "nil"
            else
                loadsave.gamedata.toolbar[invSlotFrom.id] = "nil"
            end

            return
        end

        invSlotFrom.item.x, invSlotFrom.item.y = invSlotFrom.x, invSlotFrom.y
    end
end

-- Inventory elementtien käyttämä hiiren painikkeiden kuuntelu.
local function touchListener( event )
    local target = event.target
    local phase = event.phase

    if phase == "began" then
        if target.item then
            target.touchBegan = true
			invSlotFrom = target
            invSlotFrom.item.xScale, invSlotFrom.item.yScale = 1.2, 1.2
            -- Set focus on object
            display.getCurrentStage():setFocus( target )
            -- bugi/hack-fix: inventoryn esineet ovat tässä groupissa, joka jää toolbar groupissa alle, eli
            -- siirretään se eteen aina kun johonkin kosketaan ja sitten siirretään kosketettu esine vielä sen eteen.
            group:toFront()
            target.item:toFront()
        end

	elseif phase == "moved" then
		if target.item and target.touchBegan == true then
			target.item.x, target.item.y = event.x, event.y
		end

    elseif phase == "ended" or phase == "cancelled" then
		if invSlotFrom then
			if invSlotFrom.item then
				invSlotFrom.item.xScale, invSlotFrom.item.yScale = 1, 1
				mousePositionCheck()
				invSlotFrom = nil
				-- Release focus on object
				display.getCurrentStage():setFocus( nil )
                target.touchBegan = nil
			end
		end
    end
    return true
end

-- Tarkastelee hiiren toiminnot
local function onMouseEvent( event )
	mouse.x, mouse.y = event.x, event.y

end


function inventory.newVimpain( vimpainName, index, parent, dst )
    local data = vimpainData[vimpainName]

    if data then
        if not dst[index] then
            print( "ERROR: inventory on jo täynnä, ei pystytty luomaan vimpainta: \"" .. vimpainName .. "\"" )
            return
        end

        -- Estä peliä luomasta vimpainta slottiin mihin se ei voisi normaalisti edes päätyä.
        -- (Tämä voi tapahtua vain devaajan debug ympäristössä, jossa inventory täytetään automaattisesti.)
        if dst[index].type and dst[index].type ~= data.type then
            print( "WARNING: vimpainta \"" .. vimpainName .. "\" ei voi asettaa \"" .. dst[index].type .. "\" slottiin." )
            return
        end

        local icon = data.icon or "iconMissing.png"

        local vimpain = display.newImageRect( parent, "assets/images/" .. icon, imageOptions.width, imageOptions.height )

        if not vimpain then
            print( "ERROR: assets/images/" .. icon .. " file is not found. ")
            vimpain = display.newImageRect( parent, "assets/images/Icons/iconMissing.png", imageOptions.width, imageOptions.height )
        end

        vimpain.x = dst[index].x
        vimpain.y = dst[index].y
        vimpain.slot = dst[index]
        vimpain.name = vimpainName
        vimpain.type = data.type

        dst[index].item = vimpain
    end
end


function inventory.newSlot( slotType, xStart, yStart, index, parent, dst, src )

    local column = (index-1) % columnCount
    local row = math.floor((index-1) / columnCount)


    local xOffset = column * (imageOptions.width + imageOptions.paddingHorizontal)
    local yOffset = row * (imageOptions.height + imageOptions.paddingVertical)

    local img = "iconbase.png"

    if slotType == "weapon" then
        -- img = "UnarmedIcon.png"

    elseif slotType == "armor" then
        -- img = "emptyshield.png"
        xOffset, yOffset = 0, 0

    elseif slotType == "trinket" then
        -- img = "emptyscroll.png"
        xOffset, yOffset = 0, 0

    else
        -- img = "iconbase.png"

    end

    local slot = display.newImageRect( parent, "assets/images/Icons/" .. img, imageOptions.width, imageOptions.height )
    slot.x = xStart + xOffset
    slot.y = yStart + yOffset
    -- print(index, column, math.floor((index-1) / columnCount))

    slot.id = index
    slot.src = src
    slot.type = slotType

    if src == "inventory" then
        slot:addEventListener( "touch", touchListener )
    end
    dst[index] = slot

end


function inventory.create()
    if not inventory.isOpen then
        inventory.isOpen = true

        -- Tarkastellaan onko inventory jo olemassa.
        if group ~= nil then
            return
        end

        toolbar = require( "scripts.toolbar" )

	    -- Luodaan toolbarin UI omaan ryhmäänsä, jolloin kaikki sen elementtejä voi kontrolloida yhtenä ryhmänä.
        group = display.newGroup()
        -- Lisätään inventory ryhmä toolbarin ryhmään, jolloin näiden kahden moduulin objekteja voi kontrolloida yhdessä.
        toolbar.groupRef:insert( group )

        -- Luodaan inventorylle tausta.
        local background = display.newImage( group, "assets/images/uifolder/inventorytausta.png", screen.centerX, screen.centerY - 60 )

        -----------------------------------------------------------------------------------------------

        -- Luodaan for loopilla kuvat inventory sloteista.
        for i = 1, inventorySlotCount do
            inventory.newSlot( nil, 480, 120, i, group, _G.inventorySlots, "inventory" )
        end

        inventory.newSlot( "armor", 220, 400, inventorySlotCount + 1, group, _G.inventorySlots, "inventory" )
        inventory.newSlot( "trinket", 360, 400, inventorySlotCount + 2, group, _G.inventorySlots, "inventory" )

        local textArmor = display.newText({
            parent = group,
            text = "Armor",
            x = _G.inventorySlots[#_G.inventorySlots-1].x,
            y = _G.inventorySlots[#_G.inventorySlots-1].y - _G.inventorySlots[#_G.inventorySlots-1].height*0.5 - 6,
            width = 210,
            font = native.systemFont,
            fontSize = 22,
            align = "center",
        })
        textArmor.anchorY = 1

        local textTrinket = display.newText({
            parent = group,
            text = "Trinket",
            x = _G.inventorySlots[#_G.inventorySlots].x,
            y = _G.inventorySlots[#_G.inventorySlots].y - _G.inventorySlots[#_G.inventorySlots].height*0.5 - 6,
            width = 210,
            font = native.systemFont,
            fontSize = 22,
            align = "center",
        })
        textTrinket.anchorY = 1

        for i = 1, #loadsave.gamedata.inventory do
            inventory.newVimpain( loadsave.gamedata.inventory[i], i, group, _G.inventorySlots )
        end

        -- Laitetaan toolbarin nappuloihin touchEventListener, jotta niihin voi koskea, kun inventory on auki.
        for i = 1, #_G.toolbarSlots do
            _G.toolbarSlots[i]:addEventListener( "touch", touchListener )
        end

        -----------------------------------------------------------------------------------------------

        deleteBox = display.newImageRect( group, "assets/images/Icons/emptyspell.png", imageOptions.width, imageOptions.height )

        local lastToolbarSlot = _G.toolbarSlots[#_G.toolbarSlots]
        deleteBox.x, deleteBox.y = lastToolbarSlot.x + lastToolbarSlot.width*2 + 60, lastToolbarSlot.y

        local deleteInstructions = display.newText({
            parent = group,
            text = "Drop a vimpain in the slot below to permanently destroy it.",
            x = deleteBox.x,
            y = deleteBox.y - deleteBox.height*0.5 - 10,
            width = 210,
            font = native.systemFont,
            fontSize = 14,
            align = "center",
        })
        deleteInstructions.anchorY = 1

        -----------------------------------------------------------------------------------------------

        heading = display.newText({
            parent = group,
            text = "Inventory & stats",
            x = background.x - background.width*0.265,
            y = background.y - background.height*0.5 + 32,
            -- width = 210,
            font = native.systemFont,
            fontSize = 32,
            align = "center",
        })
        heading.anchorY = 0

        updateStats()

        Runtime:addEventListener( "mouse", onMouseEvent )
    end
end


function inventory.remove()
    -- print("hello", inventory.isOpen)
    if inventory.isOpen then
        inventory.isOpen = false

        if group == nil then
            return
        end

        if tooltipTimer then
            timer.cancel(tooltipTimer)
            tooltipTimer = nil
            display.remove(tooltip)
        end

        group:removeSelf()
        group = nil

        for i in pairs(_G.toolbarSlots) do
            _G.toolbarSlots[i]:removeEventListener( "touch", touchListener )
        end


        Runtime:removeEventListener("mouse", onMouseEvent)

    end
end

return inventory