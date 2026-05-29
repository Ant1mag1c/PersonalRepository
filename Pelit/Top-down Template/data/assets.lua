local player, groupUI, groupLevel

local stateHandler = require("data.stateHandler")
local assetFunctions = {
    campfire = {
        onAct = function(self) 
            local item, qty = player:getItem("log")

            if item and qty >= self.cost and not self.reacted then
                player:handleItem(item.id, -self.cost)
                self:setSequence("burning")
                self:play()
    
            end
        end,
        
        onReact = function(self) 
            self.onAct = function(self)
                print("New function!")
            end
        end,
    },

    tree = {
        onAct = function ()
            
        end
    }

}



return {

init = function(p)
    player, groupUI, groupLevel = p.player, p.groupUI, p.groupLevel
end,

sword = {
    id = "sword",
    type = "utility",
    info = "This is a basic weapon. Swing it as you want",
    img = "assets/images/items/sword.png",
    recipe = { steel = 1},
},   

log = {
    id = "log",
    type = "material",
    info = "This is a basic crafting material. Used to feed fireplace",
    img = "assets/images/items/log.png",
},   

------------------------------------------ENVIRONMENT----------------------------------------------
tree = {
    id = "tree",
    customBody = {
        -- onAct register body
        { 
            box = {
                halfWidth = 12,
                halfHeight = 8,
                x = 0,
                y = 7,
            }
        },
        -- Body to change draw order
        { 
            isSensor = true,
            box = {
                halfWidth = 15,
                halfHeight = 25,
                x = 0,
                y = 0,
            }
        }
    }
},

campfire = {
    id = "campfire",
    cost = 5,
    customBody = { 
        {
            box = { 
                halfWidth = 7,
                halfHeight = 7,
                x = 0,
                y = -2,
            }

        }
    },
    onAct = function(self) local f = assetFunctions[self.name].onAct if f then f(self) end end,
    onReact = function(self) local f = assetFunctions[self.name].onReact if f then f(self) end end,
}   


}