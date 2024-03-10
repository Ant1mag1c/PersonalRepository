-- local inventory = {}
-- local item = {}

-- local itemT = {
--     {image="Assets/Images/sword1.png", id="weapon", name="copperS"},
--     {image="Assets/Images/sword2.png", id="weapon", name="SilverS"},
--     {image="Assets/Images/armor1.png", id="armor", name="rustyArmor"},
-- }

-- local imageG = display.newGroup()

-- -- if targetSlot.item == selectedItem then
--         --     targetSlot.item = nil
--         -- end


-- local function manageInventory( item )
--     local onSlot
--     local targetSlot

--     for i = 1, #inventory do
--         targetSlot = inventory[i]

--         -- Check if target has been moved inside slot
--         onSlot = item.x > targetSlot.bound.xMin and
--             item.x < targetSlot.bound.xMax and
--             item.y > targetSlot.bound.yMin and
--             item.y < targetSlot.bound.yMax or false

--         -- Check if item is allowed in selected slot
--         if onSlot then
--             local swapped = item and targetSlot.item and not targetSlot.block

--             if swapped then
--                 local toSwap = item
--                 local fromSwap = targetSlot.item

--                 targetSlot.item = fromSwap
--                 fromSwap.x, fromSwap.y = fromSwap.startX, fromSwap.startY
--             end

--             if not targetSlot.block then
--                 print("EQUIPPED")
--                 targetSlot.item = item
--                 item.x, item.y = targetSlot.x, targetSlot.y
--             else
--                 print("BLOCKED")
--                 item.x, item.y = item.startX, item.startY
--             end
--         end
--     end
--     print(inventory[1].item, inventory[2].item)
-- end

-- -- Handle touch event between items and inventory slots
-- local function handleTouch(event)
--     local phase = event.phase
--     local target = event.target

--     if phase == "began" then
--         display.getCurrentStage():setFocus(target)
--         target.isFocus = true
--         target.prevX = event.x - target.x
--         target.prevY = event.y - target.y

--         -- Create "cant insert here logos on all unallowed slots"
--         for i = 1, #inventory do
--             local targetInventory = inventory[i]

--             if targetInventory.type ~= target.id then
--                 local denySign = display.newText( imageG, "X", targetInventory.x, targetInventory.y, native.systemFont, 60 )
--                 denySign:setFillColor(1,0,0)
--                 targetInventory.block = denySign
--             end
--         end

--     elseif target.isFocus then
--         if phase == "moved" then
--             target.x = event.x - target.prevX
--             target.y = event.y - target.prevY
--         elseif phase == "ended" then
--             -- Reset touch focus
--             display.getCurrentStage():setFocus(nil)
--             target.isFocus = nil

--             manageInventory( target )

--             for i = 1, #inventory do
--                 if inventory[i].block then
--                     display.remove(inventory[i].block)
--                     inventory[i].block = nil
--                 end
--             end
--         end
--     end
--     return true
-- end

-- local padding = 50
-- local scale = 0.7
-- -- Create items
-- for i = 1, #itemT do
--     local newItem = display.newImageRect(imageG, itemT[i].image, 50, 50)
--     newItem.x = (i - 1) * (newItem.width) + display.contentCenterX * 0.8
--     newItem.y = display.contentCenterY * 1.5
--     newItem.id = itemT[i].id
--     newItem.startX, newItem.startY = newItem.x, newItem.y
--     newItem.xScale, newItem.yScale = scale, scale
--     newItem:addEventListener("touch", handleTouch)

--     item[i] = newItem
-- end

-- -- Create inventory slots
-- for i = 1, 2 do
--     local image = i == 1 and "Assets/Images/armor1.png" or "Assets/Images/sword1.png"
--     local slot = display.newRect(imageG, 0, 0, item[1].width + 10, 50)
--     slot.x = (i - 1) * (slot.width + 30) + display.contentCenterX * 0.5
--     slot.y = display.contentHeight - (slot.height * 0.65)
--     slot.alpha = 0.3
--     slot.bound = slot.contentBounds
--     slot.type = i == 1 and "armor" or "weapon"

--     local slotImage = display.newImageRect( imageG, image, slot.width-10, slot.height-10  )
--     slotImage.x, slotImage.y = slot.x, slot.y
--     slotImage.alpha = 0.3
--     inventory[i] = slot
--     slotImage:toBack()
--     slot:toBack()
-- end

-- --------------------------------------------------------
-- -- VERSION 2
-- ---------------------------------------------------------
-- -- local inventory = {}
-- -- local item = {}

-- -- local itemT = {
-- --     {image="Assets/Images/sword1.png", id="copperS"},
-- --     {image="Assets/Images/sword2.png", id="SilverS"},
-- -- }

-- -- local imageG = display.newGroup()

-- -- local function manageInventory(target)
-- --     local selectedItem = target
-- --     local onSlot

-- --     for i = 1, #inventory do
-- --         targetSlot = inventory[i]

-- --         if targetSlot.item == selectedItem then
-- --             targetSlot.item = nil
-- --         end

-- --         -- Check if target has been moved inside slot
-- --         onSlot = target.x > targetSlot.bound.xMin and
-- --             target.x < targetSlot.bound.xMax and
-- --             target.y > targetSlot.bound.yMin and
-- --             target.y < targetSlot.bound.yMax or false

-- --         -- Include target item to inventory slot
-- --         if onSlot then
-- --             if not targetSlot.item then
-- --                 target.x, target.y = targetSlot.x, targetSlot.y
-- --                 targetSlot.item = target
-- --             else
-- --                 target.y = display.contentCenterY*1.5
-- --             end
-- --         end
-- --     end

-- --     for i = 1, #inventory do
-- --         print( "Inventory", i, inventory[i].item )
-- --     end
-- -- end

-- -- -- Handle touch event between items and inventory slots
-- -- local function handleTouch(event)
-- --     local phase = event.phase
-- --     local target = event.target

-- --     if phase == "began" then
-- --         display.getCurrentStage():setFocus(target)
-- --         target.isFocus = true
-- --         target.prevX = event.x - target.x
-- --         target.prevY = event.y - target.y

-- --     elseif target.isFocus then
-- --         if phase == "moved" then
-- --             target.x = event.x - target.prevX
-- --             target.y = event.y - target.prevY
-- --         elseif phase == "ended" then
-- --             -- Reset touch focus
-- --             display.getCurrentStage():setFocus(nil)
-- --             target.isFocus = nil
-- --             manageInventory(target)
-- --         end
-- --     end
-- --     return true
-- -- end

-- -- local padding = 50
-- -- local scale = 0.7
-- -- -- Create items
-- -- for i = 1, #itemT do
-- --     local newItem = display.newImageRect(imageG, itemT[i].image, 50, 50)
-- --     newItem.x = (i - 1) * (newItem.width) + display.contentCenterX * 0.8
-- --     newItem.y = display.contentCenterY * 1.5
-- --     newItem.xScale, newItem.yScale = scale, scale
-- --     item[i] = newItem
-- --     newItem:addEventListener("touch", handleTouch)
-- -- end

-- -- -- Create inventory slots
-- -- for i = 1, 2 do
-- --     local slot = display.newRect(imageG, 0, 0, item[1].width + 10, 50)
-- --     slot.x = (i - 1) * (slot.width + 30) + display.contentCenterX * 0.5
-- --     slot.y = display.contentHeight - (slot.height * 0.65)
-- --     slot.alpha = 0.3

-- --     slot.bound = slot.contentBounds
-- --     slot.isOccupied = false

-- --     inventory[i] = slot
-- -- end
