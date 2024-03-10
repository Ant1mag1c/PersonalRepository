local _inv = require("Scripts.inventory")
local _itemData = require("Data.itemData")


local groupGame = display.newGroup()
local groupUI = display.newGroup()
local groupOverlay = display.newGroup()

local inventory


-- Call back from module after inventory being removed
local function onCloseInventory()
    inventory = nil
    groupUI.alpha = 1
    print("Inventory closed.")
end

local function openInventory()
    if not inventory then
        groupUI.alpha = 0.1
        inventory = _inv.show(groupOverlay, display.contentCenterX, display.contentCenterY-50, 200, 350, onCloseInventory)
    end
end
-- During pick item will be removed and reference will have isOwned as true
local function pickItem(event)
    local target = event.target
    if event.phase == "ended" then
        print("Item picked")
    end
end

local function spawnItem(itemNumber, group)
    local _data = _itemData[itemNumber]

    local item = display.newImageRect( group, _data.image, 50, 50 )
    item.x, item.y = 100, 100
    item.id, item.name, item.isOwned, item.type = _data.id, _data.name, _data.isOwned, _data.type
    item:addEventListener("touch" , pickItem)
    return item
end

local firstItem = spawnItem(1, groupGame )
print(firstItem.id)


local openButton = display.newRect(groupUI, display.contentCenterX, display.contentCenterY*1.8, 80, 50)
openButton:setFillColor(0.5)
openButton:addEventListener("touch", openInventory)
local openText = display.newText(groupUI, "Menu", openButton.x, openButton.y, native.systemFont, 25)
