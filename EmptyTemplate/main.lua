display.setStatusBar( display.HiddenStatusBar )
require( "libs.utils" )

local tools = require("libs.tools")
local screen = require("libs.screen")


----------------------------------------------------------------------------------------------

local body = {}
body.status = "idle"
--local scan = true

local scan = false
local travelTime = 2000
local info
function body.update()
    -- if scan or body.status == "aggro" then body.aggro() timer.cancel( body.leashTimer ) body.leashTimer = nil end
    if body.status == "idle" then body.idle() end

    infoPrint = info and print(info)
    info = nil
end
----------------------------------------------------------------------------------------------------



function body.idle()
    if not body.a then
        body.a = "a"
        print(body.a)
    end
end

body.update()
body.update()