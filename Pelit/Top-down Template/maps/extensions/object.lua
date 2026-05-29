local physics = require("physics")
local assets = require("data.assets")
local player

local M = {}

function M.new( instance )
    if not instance then error("ERROR: Expected display object") end

    -- Check if animation exists and turn instance into sprite
    local animations = require("maps.extensions.animations")
    if animations[instance.name] then
        local temp = {
            parent = instance.parent,
            type = instance.type,
            id = instance.id,
            name = instance.name,
            usable = instance.usable,
            x = instance.x,
            y = instance.y,
            scale = instance.scale
        }
        display.remove(instance)

        instance = display.newSprite( animations[instance.name].sheet, animations[instance.name] )
        instance.x, instance.y = temp.x, temp.y
        instance.id, instance.name, instance.usable = temp.id, temp.name, temp.usable
        instance.defaultScale = temp.scale

        instance:scale(temp.scale, temp.scale)
        temp.parent:insert(instance)
    end

    if not instance.defaultScale then instance.defaultScale = 1 end

    local data = assets[instance.name]
    if not data then print("WARNING: invalid id " .. instance.name) return end

    
    -- Copy values from data to instance
    for k, v in pairs( data ) do
        instance[k] = v
    end


    if data.customBody then
        local bodies = {}

        for k,v in pairs(data.customBody) do
            table.insert(bodies, v)
        end
        
        physics.addBody( instance, "static", unpack(bodies) )
    
    else
        -- local fileName = instance.name .. ".png"
        -- local imgName = "maps/sprites/" .. fileName

        -- local image_outline = graphics.newOutline( 2, imgName )

        physics.addBody( instance, "static" )
    end
    
    --Is object interactable? 
    local usable = instance.usable

    function instance:onEnterFrame()

        if player.y > instance.y then
            instance:toBack()
        else
            instance:toFront()
        end
        
    end

    -- Add a collision listener. 
    function instance:collision(event)
    
        if event.phase == "began" and event.other.name == "hero" then
            timer.cancel("stop")
            player = event.other

            -- Start enterFrame to monitor draw order
            Runtime:addEventListener("enterFrame", self.onEnterFrame)
            
            -- Only inner body can start fading effect
            if event.selfElement == 1 and not self.fading then
            
            if not usable then return end
            
            -- if player can interact with object then start pulsing effect
            self.fading = true
            
            local function scaleToSmall()
                if not self.fading then
                    return
                end

                transition.scaleTo(self, {
                    xScale = instance.defaultScale - 0.1,
                    yScale = instance.defaultScale - 0.1,
                    time = 800,

                    onComplete = function()
                        -- check again before continuing
                        if not self.fading then
                            return
                        end

                        transition.scaleTo(self, {
                            xScale = instance.defaultScale,
                            yScale = instance.defaultScale,
                            time = 800,
                            delay = 100,

                            onComplete = scaleToSmall
                        } )
                    end
                    } )
            end
                
            scaleToSmall()
            
            end
        end

        if event.phase == "ended" and event.other.name == "hero" then
            Runtime:removeEventListener("enterFrame", self.onEnterFrame)
            
            timer.performWithDelay( 200, function()
                self.fading = false
                transition.cancel(self)
                self.xScale = instance.defaultScale
                self.yScale = instance.defaultScale
            end, "stop" )
        end
    end

    instance:addEventListener("collision")

    return instance
end

return M