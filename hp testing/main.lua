
local button = display.newCircle(display.contentCenterX, display.contentCenterY, 30)

local health = 3
local hp1
local hp2
local hp3


local function update()
    if health == 3 then
        hp1 = display.newCircle( 50, 10, 20, 10 )
        hp2 = display.newCircle( 100, 10, 20, 10 )
        hp3 = display.newCircle( 150, 10, 20, 10 )

    elseif health == 2 then
        display.remove( hp3 )

    elseif health == 1 then
        display.remove( hp2 )

    else display.remove( hp1 )
        display.remove( button)

    end
end

update()

local function isDead()
    local text = display.newText({
        	text = "All health spent.",
         	x = display.contentCenterX,
            y = display.contentCenterY,
         	font = native.systemFont,
         	fontSize = 30,
              } )
end

local function onClickEvent( event )
    if event.phase == "began" then
        health = health - 1
    
    elseif event.phase == "ended" then
        print( health )
        update()
    
        if health == 0 then
            isDead()
            
    
        end
    end
end


button:addEventListener( "touch", onClickEvent )
-- Runtime:addEventListener( "enterFrame", update)