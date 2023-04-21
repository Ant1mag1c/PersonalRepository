local enemy = {}
local cardScript = require("Scripts.Card")

local function playOnEnemy(event)

    if event.phase == "began" then
        if not cardScript.activeCard == nil then
            print("aktiivista korttia ei ole")
        elseif ( not cardScript.activeCard == nil) then
            print("aktiivinen kortti: " and cardScript.activecard.name)
        end
    end
end

function enemy.newEnemy( x, y )
    local x = 150
    local y = 100

    local enemyWidth = 80
    local enemyHeight = 80

    local newEnemy = display.newRect( x or 0, y or 0, enemyWidth, enemyHeight )  
    newEnemy:setFillColor( 1,0,0 )

    newEnemy:addEventListener("touch", cardScript.playCard)

    newEnemy.type = "enemy"

    --[[
    newEnemy.image = display.newImageRect(newEnemy,"Assets/Images/" .. data.image, 65, 65)
    newEnemy.image.x, newEnemy.image.y = 0, -cardHeight*0.175

    newEnemy.frame = display.newImageRect(newEnemy, "Assets/Images/" .. data.frame, 78, 78 )
    newEnemy.frame.x, newEnemy.frame.y = 0, -cardHeight*0.175 - 2

    newEnemy.name = display.newText(newEnemy, data.name, 30, 22, titleWidth, titleHeight, native.systemFont, 10)

    newEnemy.description = display.newText(newEnemy, data.description, 5, 60 , textWidth, textHeight, native.systemFont, 7)

    newEnemy.hp = display.newText(newEnemy, data.hp, 20 , 20, native.systemFont, 7)]]

    --newEnemy:addEventListener("touch", playOnEnemy)
    return newEnemy
end

return enemy