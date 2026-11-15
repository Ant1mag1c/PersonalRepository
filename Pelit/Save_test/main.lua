require("scripts.utils")

local screen = require("scripts.screen")
local loadsave = require("scripts.loadsave")


local data = { value = 1}
local newFile, removeFile, read, update

local btnL = {
    { id = "new",label = "CREATE", x = 120, action = function() newFile() end},
    { id = "del",label = "DELETE", x = screen.maxX - 120, action = function() removeFile() end },
    { id = "read",label = "READ", y = 160, action = function() read() end },
    { id = "update",label = "UPDATE",x = screen.maxX - 120, y = 160, action = function() update() end },
}

local function checkFile()
    local path = system.pathForFile("file", system.DocumentsDirectory)
    local file = io.open(path, "r")

    if file then
        file:close()
        return true, path
    end

    return false, path
end


for i = 1, #btnL do
    local d = btnL[i]
    local width, height = 200, 50
    local x, y = d.x or 120, d.y or 80

    local btn = display.newGroup()
    btn.id = d.id

    local frame = display.newRect( btn, x, y, width, height )
    local label = display.newText( d.label, frame.x, frame.y, native.systemFontBold, 18 )

    frame:setFillColor(0.2)
    label:setFillColor(0.7)

    btn.touch = function( self, event )
        local p, t = event.phase, event.target
        -- print( p, t.id, self )

        if p == "began" then
            frame:setFillColor(0.5, 0, 0)
            if d.action then
                d.action()
                print( "" )
                print("----------------------------")
            end

        elseif p == "ended" then
            frame:setFillColor(0.2)
        end
    end


    btn:addEventListener("touch", btn )
end

function newFile()
    local handle = checkFile()

    if handle then
        print( "WARNING: File exists!" )
    else
        print( "New file!" )
        loadsave.save( data, "file" )
    end

end

function removeFile()
    local _, path = checkFile()
    local success = os.remove(path)

    if success then
        print("File deleted!")
    else
        print( "WARNING:, File not found")
    end
end

function read()
    if not checkFile() then
        print("WARNING: Nothing to read ")

    else
        table.print( loadsave.load( "file" ))
    end

end

function update()
    local handle = checkFile()

    if not handle then
        print( "WARNING:, File not found")

    else
        data = { value = math.random( 1, 100 ) }
        loadsave.save( data, "file" )
        print("Updated value!")
    end


end
