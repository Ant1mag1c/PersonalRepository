local x = x or display.contentCenterX
local y = y or display.contentCenterY

local obj = {}
local itemSlot = {}

local isInsideBounds


local function handleItemSlots( object )
    -- TODO: Equipped taulu täytyy luoda funktion ulkopuolella
    itemSlot.equippedItem = {}
    -- print(item.id)
    local targetSlot
    for i = 1, #itemSlot do
        targetSlot = itemSlot[i]
        --Tarkistetaan onko objecti irroitettu slotin sisällä
        if object.x > targetSlot.bounds.xMin and
            object.y > targetSlot.bounds.yMin and
            object.x < targetSlot.bounds.xMax and
            object.y < targetSlot.bounds.yMax then
                -- TODO: Jatka tästä
            -- Tarkistetaan onko Kyseisessä slotissa jo itemiä ja jos on niin tarkistetaan
            -- Onko target objekti tullut slotista vai uutena
            isInsideBounds = true

            object.x, object.y = targetSlot.x, targetSlot.y
            break
        else
            isInsideBounds = false

            if targetSlot.equippedItem then
                -- print("Poistetaan objectin equippedItem status edelliseltä slotilta")
                targetSlot.equippedItem = nil
            end
        end
    end
    -- Käsitellään itemslotin dataa
    if isInsideBounds then
        if object ~= targetSlot.equippedItem then
            if not targetSlot.equippedItem then
                targetSlot.equippedItem = object
                print( targetSlot.equippedItem.id .. " in slot " .. targetSlot.id )
            else
                -- Kyseisessä slotissa on jo ennestään objekti
                print("You already have item in this slot")
                object.x, object.y = x, y
            end
        else
            print("This item is already in current slot")
            -- object.x, object.y = originalX, originalY
        end
    else
        print(object.id .. " is not equipped " )
        targetSlot.equippedItem = nil
    end
end

local originalX, originalY

local function moveObject( event )
    local target = event.target
    local phase = event.phase

    if event.phase == "began" then
        -- Code to execute when the touch begins
        originalX, originalY = event.x, event.y
        display.getCurrentStage():setFocus(target)
        target.isFocus = true
        target.xScale, target.yScale = 1.2, 1.2
        -- print( "Touch happened on " .. target.id)

        -- Save the initial touch position
        target.touchOffsetX = event.x - target.x
        target.touchOffsetY = event.y - target.y

    elseif target.isFocus then
        if event.phase == "moved" then
            target.x = event.x - target.touchOffsetX
            target.y = event.y - target.touchOffsetY

        else
            -- Objectista on irroitettu
            target.xScale, target.yScale = 1, 1
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
            handleItemSlots( target )
        end
    end

    return true  -- To prevent other objects from catching the touch event
end

local colorTable =

    {
        red = {1,0,0, color="red"},
        green={0,1,0, color="green"},
        blue={0,0,1, color="blue"}

    }

-- print(colorTable.red.color)

-- Luodaan itemSlotit
for i = 1, 3 do
    itemSlot[i] = display.newRect( (i-1) * 90 + 70, y*1.8, 80, 80)
    itemSlot[i]:setFillColor( 0.5 )
    itemSlot[i].bounds = itemSlot[i].contentBounds
    itemSlot[i].id = "Slot " .. i
end
-- print(itemSlot[1].bounds.xMax)

--Luodaan liikutettavat objektit
local objectX = 100
for i = 1, 3 do
    local bodyColor = i == 1 and colorTable.red or i == 2 and colorTable.green or colorTable.blue

    obj[i] = display.newCircle( (i-1) * objectX + 50, y, 26 )
    obj[i]:setFillColor( bodyColor[1], bodyColor[2], bodyColor[3] )
    obj[i].id = "object " .. bodyColor.color
    obj[i]:addEventListener( "touch", moveObject)
end