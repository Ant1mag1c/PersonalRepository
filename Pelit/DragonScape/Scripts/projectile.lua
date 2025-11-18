local calc = require( "Scripts.calc" )
local gamedata = require( "Scripts.gamedata" )

local t = {}

local options =

{
	width = 64,
	height = 62,
	numFrames = 8,
}


local animation = {
    {
        name = "move",
        start = 1,
        count = 8,
        time = 1000,
    }
}

local imageSheet = graphics.newImageSheet( "Images/fireball.png", options )

local projectile

function t.new( group, x, y, target )
    projectile = display.newSprite( group, imageSheet, animation )
    projectile.x, projectile.y = x, y
	projectile.tileType = "enemy"
    projectile.speed = 300

    local result = calc.getAngle( projectile, target )

    projectile.rotation = result.angle + 180

    physics.addBody(projectile, { radius=10, isBullet=true, isSensor = true, bodyType = "kinematic" })
    projectile.gravityScale = 0
    projectile:play()

    function projectile.start()
        local vx = math.cos(result.angleInRad) * projectile.speed
        local vy = math.sin(result.angleInRad) * projectile.speed

        if not gamedata.projectileFreeze then
            projectile:setLinearVelocity(vx, vy)
        end
    end

    function projectile.stop()
        projectile:setLinearVelocity( 0,0 )
    end


    projectile.start()
    return projectile

end

return t