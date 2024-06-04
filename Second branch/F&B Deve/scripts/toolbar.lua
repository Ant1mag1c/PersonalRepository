_G.toolbarSlots = {}

local toolbar = {}
toolbar.groupRef = nil

local screen = require( "scripts.screen" )
local inventory = require( "scripts.inventory" )
local loadsave = require( "scripts.loadsave" )

local toolbarSlotCount = 4
for i = 1, toolbarSlotCount do
    if not loadsave.gamedata.toolbar[i] then
        loadsave.gamedata.toolbar[i] = "nil"
    end
end

local group


function toolbar.use( target )
	if not target.onCooldown then

	end
end


function toolbar.create( parent )
	-- Jos toolbar on jo olemassa, niin ei luoda uutta päällekäistä toolbaria.
	if group ~= nil then
		return
	end

	-- Luodaan toolbarin UI omaan ryhmäänsä, jolloin kaikki sen elementtejä voi kontrolloida yhtenä ryhmänä.
	-- Lisätään myös viittaus ryhmään, jotta sitä voidaan käyttää inventory moduulissa.
	group = display.newGroup()
	toolbar.groupRef = group
	-- Lisätään ryhmä game scenen sceneGrouppiin, jolloin se ei vaan jää kaiken eteen.
	parent:insert( group )

	local slotType = {
		"weapon"
	}

	-- Luodaan toolbar slotit.
	for i = 1, toolbarSlotCount do
		inventory.newSlot( slotType[i], 360, screen.maxY - 80, i, group, _G.toolbarSlots, "toolbar" )
	end

	-- Luodaan vimpaimet toolbariin.
	for i = 1, #loadsave.gamedata.toolbar do
		inventory.newVimpain( loadsave.gamedata.toolbar[i], i, group, _G.toolbarSlots )
	end

end

function toolbar.remove()
	if group == nil then
        return
    end

    group:removeSelf()
    group = nil
	toolbar.groupRef = nil
end

return toolbar