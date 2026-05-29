-- Inventory ui and usability
local ui = require("libs.effects")
local screen = require("classes.screen")
local widget = require("widget")

local cx, cy = screen.centerX, screen.centerY
local minX, minY = screen.minX, screen.minY
local maxX, maxY = screen.maxX, screen.maxY
local sw, sh = screen.width, screen.height

--main frame contentBounds
local bounds = {} 


local bgImage = "assets/images/ui/inventory.png"

-- Data tables for objects
local slots = {}
local buttons = {}
local selectedBtn = {}

-- Order in which frames are created
local createOrder = { "window", "item", "info", "utils" }

-- Listed frame objects. Updated after first frame is generated
local frames = {
    window = {
        x = cx,
        y = cy,
        width = sw-50,
        height = sh-50,
    }
}

-- Listed text objects
local textOptions = {
    Inventory = { x = cx, y = minY + 34, size = 18  },
    Utilities = { x = cx-70, y = cy+43, size = 12  },
    -- Description = { x = cx+135, y = minY + 35, size = 18  },
}

-- List navigation keys
local navKeys = {
    a = "left",
    d = "right",
    w = "up",
    s = "down",
    enter = "enter",
}

-- Functions declare
local onTouch, onKey, newButton, getFramesData, updateInfo, handleNavigation

--------------------------------------------------------------------------------------------------------
local inventory = {}

function inventory:open( params )

    print( "Inventory opened")
    params = params or {}
    
    if params.onPause then params.onPause() end
    if params.onResume then self.onResume = params.onResume end
    local player = params.player

    local group = display.newGroup()
    params.parent:insert(group)

    local newDimmer = ui:getDimmer()
    group:insert(newDimmer)

    -- Generate all frame windows
    for i = 1, #createOrder do
        local t = createOrder[i]
        local d = frames[t]

        local frame = display.newRect( group, d.x, d.y, d.width, d.height )
        
        if i == 1 then
            bounds = frame.contentBounds

            local newFrames = getFramesData(bounds)
            
            for k, v in pairs(newFrames) do
                frames[k] = v
            end

        else
            -- Set anchor point to top-left
            frame.anchorX = 0
            frame.anchorY = 0
        end

        -- Main window had darker brown color
        frame:setFillColor( unpack( i == 1 and {0.36, 0.20, 0.11} or {0.659, 0.424, 0.23} ) )
        frame.strokeWidth = 3
        frame:setStrokeColor( unpack( { 0.18, 0.10, 0.05 } ) )
    end

    -- Create texts
    for k, v in pairs(textOptions) do
        local text = display.newText( group, k, v.x, v.y )
        text.size = v.size
        text:toFront()
    end

    --------------------------------------------------------------------------------
    -- Create buttons

    local btnExit = widget.newButton({
        id = "exit",
        x = bounds.xMax - 10,
        y = minY + 35,
        width = 16,
        height = 16,
        label = "X",
        labelXOffset = 1,
        fontSize = 20,
        font = "assets/fonts/fonts/munro.ttf",
        shape = "rect",
        labelColor = {default = { 0 }, },
        fillColor = { default = { 143/255, 37/255, 42/255 }, over = { 143/255, 37/255, 42/255 } },
        strokeColor = { default = { 0.29, 0.17, 0.10 }, over = { 0.29, 0.17, 0.10 } },
        strokeWidth = 3,
        onEvent = onTouch
    } )
    
    local btnCraft = widget.newButton({
        id = "craft",
        x = bounds.xMin + 45,
        y = minY + 35,
        width = 80,
        height = 14,
        label = "TO CRAFTING",
        labelXOffset = 1,
        fontSize = 16,
        font = "assets/fonts/fonts/munro.ttf",
        shape = "rect",
        labelColor = {default = { 0 }, },
        fillColor = { default = { 27/255, 99/255, 19/255 }, over = { 27/255, 99/255, 19/255 } },
        strokeColor = { default = { 0.29, 0.17, 0.10 }, over = { 0.29, 0.17, 0.10 } },
        strokeWidth = 3,
        onEvent = onTouch
    } )
    
    local btnUse = widget.newButton({
        id = "use",
        x = bounds.xMax - 85,
        y = bounds.yMax - 25,
        width = 60,
        height = 18,
        label = "USE ITEM",
        labelXOffset = 1,
        fontSize = 16,
        font = "assets/fonts/fonts/munro.ttf",
        shape = "rect",
        labelColor = {default = { 0 }, },
        fillColor = { default = { 67/255, 67/255, 153/255 }, over = { 67/255, 67/255, 153/255 } },
        strokeColor = { default = { 0.29, 0.17, 0.10 }, over = { 0.29, 0.17, 0.10 } },
        strokeWidth = 3,
        onEvent = onTouch
    } )
    btnUse.set = function (self, state) 
        if state == nil then return end
        if state == false then
            self.alpha = 0
            self:setEnabled(false)
        elseif state == true then
            self.alpha = 1
            self:setEnabled(true)
        end
    end

    group:insert(btnExit)
    group:insert(btnCraft)
    group:insert(btnUse)
    
    buttons["exit"] = btnExit
    buttons["craft"] = btnCraft
    buttons["use"] = btnUse

    btnUse:set(false)

    --------------------------------------------------------------------------------
    -- Create slots
    local rows = 6
    local cols = 7
    local padding = 7
    local size = 28
    local utilRows = 1 -- Creates (this value + 1) rows
    local firstX = bounds.xMin + size + padding
    local firstY = bounds.yMin + size + 14

    local inventory = player.inventory
    local _temp = {}

    -- Sort inventory in same order
    table.sort(inventory, function(a, b)
        if a.type == b.type then
            return a.id < b.id
        end

        return a.type < b.type
    end)

    -- Copy inventory into temporary table
    for k, v in pairs(inventory) do
        table.insert(_temp, v)
    end

    -- Create slots
    for i = 1, rows do
        slots[i] = {}
        for j = 1, cols do

            local frame = widget.newButton({
                id = "slot",
                x = firstX,
                y = firstY,
                width = size,
                height = size,
                label = "",
                labelYOffset = 8,
                labelXOffset = 7,
                fontSize = 10,
                font = "assets/fonts/fonts/munro.ttf",
                shape = "rect",
                fillColor = { default={ 0.83, 0.77, 0.63 }, over={ 0.83, 0.77, 0.63 } },
                strokeWidth = 3,
                strokeColor = { default={ 0.29, 0.17, 0.10 }, over={ 0.29, 0.17, 0.10 } },
            } )

            -- Set slots to correct row positions
            if i == (rows - utilRows) then
                -- First util row
                frame.y = i == (rows - utilRows) and cy + 70            
            else
                -- Rest goes below previous row
                frame.y = slots[i - 1] and (slots[i - 1][j].y + size + padding) or firstY
            end
            
            frame.x = slots[i][j - 1] and (slots[i][j - 1].x + size + padding) or firstX
            frame:addEventListener("touch", onTouch)
            frame.row, frame.col = i, j
            
            -- Assign item to frame
            local item = _temp[1]
            frame.item = item
            table.remove(_temp, 1)
            
            group:insert(frame)
            slots[i][j] = frame
            buttons[frame] = frame

            local offset = 2

            -- Create item image or gray out slot
            if item then
                if item.img then
                    local img = display.newImageRect( group, item.img, 16, 16 )
                    img.x, img.y = frame.x, frame.y - offset
                    frame.img = img

                    frame:setLabel("x"..item.qty)
                end
            else
                frame.alpha = 0.7
            end
        end
    end

    -- Set default selected button
    selectedBtn = slots[1][1]

    local selectMark = display.newImageRect( group, "assets/images/ui/finger.png", 64, 64 )
    selectMark:scale(0.2, 0.2)
    selectMark.move = function (self)
        self.x, self.y = selectedBtn.x + 5, selectedBtn.y + 10
        display.remove(inventory.infoText)
        print("move select")

        selectedBtn:scale(0.9, 0.9)
        if selectedBtn.img then selectedBtn.img:scale(0.9, 0.9) end 

        if selectedBtn.item then 
            updateInfo(selectedBtn.item, selectedBtn.parent) 
        end
    end

    selectMark:move()

    self.selectMark = selectMark
    
    -- Create finalize function
    function group:finalize()
        -- print( "finalize!" )
        Runtime:removeEventListener( "key", onKey )

        slots = {}
        buttons = {}
        selectedBtn = {}
    end
    
    -- Listeners
    group:addEventListener( "finalize" )
    Runtime:addEventListener( "key", onKey)
        
    return group
end

-- Disable buttons and close inventory
function inventory:destroy()
    for k,v in pairs(buttons) do
        v:setEnabled(false)
    end

    self.onResume()
end

-- Handle all button events
function onTouch(e)

    local target, img = e.target, e.target.img
    local id = target.id

    if e.phase == "began" then
        selectedBtn = target
        inventory.selectMark:move()

        return true
    end

    if e.phase == "onEnter" then

        if id == "exit" then
            inventory:destroy()
        elseif id == "craft" then
            -- Close inventory and open crafting menu
        elseif id == "slot" then
            if target.item then 
                buttons["use"]:set(true)

            else
                buttons["use"]:set(false)
            end
        end

        return true
    end

    return true
end

-- Closing and navigation keyEvents
function onKey(e)
    local key, phase, selectMark = e.keyName, e.phase, inventory.selectMark
    if ( key == "tab" or key == "i") and phase == "down" then 
        if inventory.onResume then inventory.onResume() end
    elseif navKeys[key] and phase == "down" then
        handleNavigation( navKeys[key] )
    end
end

-- Return frame data with updated contentBounds
function getFramesData(bounds)
    return {
        item = {
            x = bounds.xMin + 15,
            y = bounds.yMin + 20,
            width = sw - 225,
            height = sh - 170,
        },

        info = {
            x = bounds.xMax - 150,
            y = bounds.yMin + 20,
            width = 135,
            height = sh - 80,
        },

        utils = {
            x = bounds.xMin + 15,
            y = bounds.yMax - 85,
            width = sw - 225,
            height = sh - 245,
        }
    }
end

-- Update info panel with slot item
function updateInfo( item, parent )
    if inventory.infoText then
        display.remove(inventory.infoText)
    end

    local use = buttons["use"]
    use.alpha = 1


    local newGroup = display.newGroup()
    parent:insert(newGroup)

    local infoMsg = item.info
    if not infoMsg then print("No item info") return end

    local options = {
        parent = newGroup,
        text = infoMsg,
        x = bounds.xMax - 80,
        y = bounds.yMin + 190,
        width = 130,
        height = 150,
        fontSize = 14,
    }
    local label = string.upper(item.id)
    local infoText = display.newText( options )
    local labelText = display.newText( newGroup, label, infoText.x-5, bounds.yMin + 35, "assets/fonts/fonts/munro.ttf", 18 )
    
    local img = display.newImageRect( newGroup, item.img, 16, 16)
    img.x, img.y = labelText.x, labelText.y + 40
    img:scale(3, 3)

    inventory.infoText = newGroup
end

-- Function for moving selected slot
function handleNavigation( key )
    local prevSelected = selectedBtn

    -- Enter key send different phase thans wasd
    if key == "enter" then
        local btn = selectedBtn

        btn:dispatchEvent({
            name = "touch",
            target = btn,
            phase = "onEnter",
            x = btn.x,
            y = btn.y,
        })

        return
    end

    selectedBtn:dispatchEvent({
        name = "touch",
        target = selectedBtn,
        phase = "began",
        x = selectedBtn.x,
        y = selectedBtn.y
    })

    -- Scale slot back to original size
    local sb = selectedBtn
    sb.xScale = 1
    sb.yScale = 1
    
    if sb.img then 
        sb.img.xScale = 1 
        sb.img.yScale = 1
    end 

    -- slot[col][row]
    local row, col = sb.row, sb.col --Col = left/right
    local finger = inventory.selectMark
    
    local id = selectedBtn.id
    local useIsActive = buttons["use"].alpha == 1 and true or false

    local navMap = {
        craft = {
            right = buttons["exit"],
            down = slots[1][1],
        },
        
        exit = {
            left = buttons["craft"],
            down = buttons["use"]
        },
        
        use = {
            up = buttons["exit"],
            left = inventory.lastItemSlot or slots[6][7]
        },

    }

    if navMap[id]  then
        if navMap[id][key] then
            local nextButton = navMap[id][key] 
            local id = nextButton.id

            
            selectedBtn = nextButton
        end

        finger:move()
        return
    end
    
    -- Handle slot movement
    if key == "left" then
        col = col - 1
    elseif  key == "right" then
        local currSlot = slots[row][col]
        local nextSlot = slots[row][col+1]
        
        col = col + 1
        
        -- Save last item holding slot into inventory
        if useIsActive and col > 7 or 
            not nextSlot.item then
            inventory.lastItemSlot = currSlot
        
            selectedBtn = buttons["use"]
            finger:move()
            return
        end

    elseif  key == "up" then
        row = row - 1

        if row < 1 then
            selectedBtn = buttons["craft"]
            finger:move()
            return
        end
    elseif  key == "down" then
        local nextSlot = slots[row+1][col]
        if not nextSlot.item then
            selectedBtn:scale(0.9, 0.9)
            return
        end
        row = row + 1
    end
    
    row = math.min(6, math.max(1, row))
    col = math.min(7, math.max(1, col))    

    selectedBtn = slots[row][col]
    
    print("col " .. col, "row " .. row)
    finger:move()
end


return inventory