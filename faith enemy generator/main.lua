math.randomseed( os.time() )
display.setStatusBar( display.HiddenStatusBar )


local enemyPool = {
    --Name, dmg, hp, location
    { "Dog", 3, 10, "forest" },
    { "Cat", 5, 7, "forest" },
    { "Cow", 3, 15, "farm" },
    { "Chicken", 1, 5, "farm" }
    
}

local pick

--generate farm enemy
-- local pick = math.random(#enemyPool)
while (enemyPool[pick][4] == "forest") do
    pick = math.random(#enemyPool)
end


    print( "You encountered: " .. enemyPool[pick][1],
            "HP: " .. enemyPool[pick][3],
            "Attack: " .. enemyPool[pick][2] )
    

