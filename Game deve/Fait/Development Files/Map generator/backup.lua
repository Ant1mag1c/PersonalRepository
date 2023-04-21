local centerX = display.contentCenterX
local centerY = display.contentCenterY
local height = display.contentHeight
local width = display.contentWidth

local treeCount = 2
local treeCenterX = centerX / 2

local tree1 = {
                xMin = 0, xMid = treeCenterX, xMax = centerX 
}

local tree2 = {
                xMin = centerX, xMid = centerX+treeCenterX, xMax = width
}


local column = {}
local columnCount = 6
local columnHeight = height / columnCount
local columnCenterY = columnHeight / 2

local stepCount = 0
local step = {}
local stepsInColumn

local currentStep

local lastStepCount

local columnX = centerX
local columnY = height - columnCenterY

local newStepX = {}
local newStepY = {}
local lastStepX = {}
local lastStepY = {}




local function createStep(x, y, width, height )
    local step = display.newRect( x, y, width, height )

    return step
end


-- column[j] = display.newRect(tree1.xMin+treeCenterX, columnY, 50, 50)
local function generateMap()
    local newX, newY = newStepX[1], newStepY[1]
    local lastX, lastY = lastStepX[1], lastStepY[1]

    local newX2, newY2 = newStepX[2], newStepY[2]
    local lastX2, lastY2 = lastStepX[2], lastStepY[2]

    local nextStepCount

    -- for j = 1, treeCount do
        for i = 1, 6 do
            step[i] = currentStep
            --Tämä ajetaan vain kerran
            if i == 1 then
                currentStep = createStep(centerX, columnY, 50, 50)
                newX = currentStep.x
                newY = currentStep.y
                nextStepCount = 1
            end

            if i == 2 then
                lastStepCount = 1
                currentStep = createStep(tree1.xMid, columnY, 50, 50)
                newX = currentStep.x
                newY = currentStep.y
            end

            if i >= 3 then
                nextStepCount = math.random(1,2)

                if lastStepCount == 1 or 2 then 
                    if nextStepCount == 2 then
                        currentStep = createStep(tree1.xMid-100, columnY, 50, 50) --vas
                        currentStep2 = createStep(tree1.xMid+100, columnY, 50, 50) --oik
                        newX = currentStep.x
                        newY = currentStep.y

                    elseif nextStepCount == 1 then
                        currentStep = createStep(tree1.xMid, columnY, 50, 50) --vas
                        newX = currentStep.x
                    end

                end

                --create lines

                --new/old coord
            end



            if newX and newY and lastX and lastY then
                print("true")
                local line = display.newLine( newX, newY, lastX, lastY )
                line.strokeWidth = 3
            end

            lastStepCount = nextStepCount

            lastX = newX
            lastY = newY
            newX = nil
            newY = nil

            columnY = columnY - columnHeight
        end

end


generateMap()