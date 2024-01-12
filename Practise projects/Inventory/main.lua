local x = x or display.contentCenterX
local y = y or display.contentCenterY

local obj = {}
local itemSlot = {}


local isInsideBounds


local function handleItemSlots( object, prevX, prevY )
    local isFromSlot = false
    local fromSlot
    local targetSlot
    for i = 1, #itemSlot do
        targetSlot = itemSlot[i]
        --Tarkistetaan onko objektista irroitettu slotin sisällä
        if object.x > targetSlot.bounds.xMin and
            object.y > targetSlot.bounds.yMin and
            object.x < targetSlot.bounds.xMax and
            object.y < targetSlot.bounds.yMax then
            -- TODO: Jos objekti siirtyy slotista varattuun slottiin niin voisi objektit vaihtaa
            -- keskenään paikkaa

            for i = 1, #itemSlot do
                if itemSlot[i].equippedItem == object then
                    isFromSlot = true
                    fromSlot = itemSlot[i]
                    break
                end
            end

            isInsideBounds = true
            object.x, object.y = targetSlot.x, targetSlot.y
            break
        else
            isInsideBounds = false
        end
    end

    if isFromSlot then
        -- print( "isFromSlot ", isFromSlot, fromSlot.id )
    end
    -- Tarkistetaan onko valittu objekti otettu slotista

    -- Käsitellään itemslotin dataa
    print("--------------------")
    if isInsideBounds then
        if not isFromSlot then
            if object ~= targetSlot.equippedItem then
                if not targetSlot.equippedItem then
                    targetSlot.equippedItem = object
                    -- Poistetaan objektin viittaus muilta sloteilta
                    for i = 1, #itemSlot do
                        if itemSlot[i].equippedItem == object then
                            if itemSlot[i] ~= targetSlot then
                                print("Removed object from " .. itemSlot[i].id)
                                itemSlot[i].equippedItem = nil
                            end
                        end
                    end
                    print( targetSlot.equippedItem.id .. " in slot " .. targetSlot.id )

                -- Kyseisessä slotissa on jo ennestään objekti
                else
                    if not isFromSlot then
                        print("You already have item in this slot")
                        object.x, object.y = prevX, prevY
                    -- Vaihdetaan itemien slotit keskenään
                    else
                        print("Swap items")

                    end
                end
            else
                print("This item is already in current slot")
            end
        -- Objekti on siirretty slotilta ja taulut vaihdetaan keskenään
        else
            print("Swap these two tables")
            local _swapSlot =
                {
                    item1 = fromSlot.equippedItem,
                    item2 = targetSlot.equippedItem

                }
                -- print(targetSlot.equippedItem)
                -- print(fromSlot.equippedItem)
            targetSlot.equippedItem = _swapSlot.item1
            fromSlot.equippedItem = _swapSlot.item2

        end
    else
        print(object.id .. " is not equipped " )
        -- Poistetaan objektin viittaus slotilta
        for i = 1, #itemSlot do
            if itemSlot[i].equippedItem == object then
                print( object.id .. " removed from slot " .. itemSlot[i].id )
                itemSlot[i].equippedItem = nil
                break
            end
        end
    end

    print("-------------------")
    print("Slot 1: ", itemSlot[1].equippedItem)
    print("Slot 2: ", itemSlot[2].equippedItem)
    print("Slot 3: ", itemSlot[3].equippedItem)
end

---------------------------------------------
local originalX, originalY

local function moveObject( event)
    local target = event.target
    local phase = event.phase

    if event.phase == "began" then
        originalX, originalY = target.x, target.y
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
            -- print( "Mouse original pos: ", originalX, originalY)
            -- Objectista on irroitettu
            target.xScale, target.yScale = 1, 1
            display.getCurrentStage():setFocus(nil)
            target.isFocus = false
            handleItemSlots( target, originalX, originalY )
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