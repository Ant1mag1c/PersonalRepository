-- PonyTiled extension for the hero object.

local animations = require( "maps.extensions.animations" )
local maths = require("libs.maths")
local loadsave = require( "classes.loadsave" )
local assets = require( "data.assets" )

-- Clear saved inventory and needs files during module loading
if loadsave.load( "inventory" ) then
	loadsave.remove("inventory")
	print( "Inventory cleared from memory" )
end

local M = {}

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Store placement from the Tiled map object and get its parent layer.
	local parent = instance.parent
	local x, y = instance.x, instance.y
	display.remove( instance )

	-- Load sprite sheet.
	local sheetOptions = { width = 20, height = 40, numFrames = 24 }
    local sheet = graphics.newImageSheet( "assets/images/characters/player.png", sheetOptions )

	-- Build hero display group with animated sprite.
	instance = display.newGroup()
	instance.sprite = display.newSprite( sheet, animations.hero )
	instance.sprite.anchorY = 0.5
	instance:insert( instance.sprite )
	instance.sprite:setSequence( "idleSouth" )
	instance.sprite:play()
	parent:insert( instance )
	instance.x, instance.y = x, y
	instance:scale(0.8, 0.7)

	instance.name = "hero"
	instance.type = "hero"
	instance.speed = 80
	instance.currentSequence = "idleSouth"
	instance.isAttacking = false
	instance.attackDir = nil


	-- Add physics body.
	physics.addBody( instance, "dynamic", { radius = 7, density = 2.5, bounce = 0, friction = 1 } )
	instance.isFixedRotation = true
	instance.linearDamping = 15

	instance.inventory = loadsave.load("inventory") or {} 

	-- Move the hero using normalised velocity from the controls module.
	function instance:move( vx, vy )
		if self._isRemoved then return end
		self.inputVX = vx
		self.inputVY = vy
		local speed = self.speed
		self:setLinearVelocity( vx * speed, vy * speed )
	end

	function instance:attack( dir )
		if self.isAttacking then return end
		self.isAttacking = true
		
		self.attackDir =
			dir == "up" and "North" or
			dir == "right" and "East" or
			dir == "down" and "South" or
			dir == "left" and "West" or nil


		-- Determine facing direction from animation sequence.
		local seq = string.lower( self.attackDir or "attackSouth" )
		local dirX, dirY = 0, 0

		if seq:find( "north" ) then dirY = -1
		elseif seq:find( "south" ) then dirY = 1
		elseif seq:find( "east" ) then dirX = 1
		elseif seq:find( "west" ) then dirX = -1
		end

		-- Cast a short ray from just past the player's collision radius.
		local px, py = self.x, self.y
		local startOffset = 2  -- pixels past player center to avoid self-hit
		local reach = 20       -- max interaction distance in pixels
		local fromX = px + dirX * startOffset
		local fromY = py + dirY * startOffset
		local toX = px + dirX * reach
		local toY = py + dirY * reach

		local hits = physics.rayCast( fromX, fromY, toX, toY, "sorted" )
		local found = false

		-- local line = display.newLine( parent, fromX, fromY, toX, toY )
		-- line.strokeWidth = 2
	end

	-- Stop all movement.
	function instance:stop()
		if self._isRemoved then return end
		self.inputVX = 0
		self.inputVY = 0
		self:setLinearVelocity( 0, 0 )
	end

	function instance:handleItem( id, value )
		if not id or not value then
			print("handleItem can't run")
			return false
		end

		local data = assets[id]

		if not data then
			print("WARNING: No asset found ", id)
			return false
		end

		local inventory = self.inventory 

		-- Check if value is plus or minus
		local itemRef = inventory[id]

		local newQty = ( itemRef and itemRef.qty + value or value )  
		
		-- Remove
		if value < 0 then
			if not itemRef then return end
			itemRef.qty = newQty
			
			-- Remove item if no more left
			if itemRef.qty < 1 then
				print("removed: ", id)
				inventory[id] = nil
			end

		else
			-- Add qty
			if itemRef then
				-- Only one utility item can be in inventory
				if itemRef.type == "utility" then return end

				itemRef.qty = newQty
				print( "Increase item qty" )	
			
			else
				-- Copy data from assets
				local newItem = {
					id = data.id,
					info = data.info,
					qty = value,
					img = data.img,
					type = data.type,
					onUse = data.onUse,
				}

				if newItem.type == "utility" then
					newItem.qty = 1
				end

				self.inventory[id] = newItem
			-- print("Added new item " .. id)
			end
		end

		loadsave.save( self.inventory, "inventory" )
	end

	function instance:handleNeed( id, value)
	end
	
	function instance:getItem( id )
		if not assets[id] then
			print("WARNING: Invalid ref id")
			return
		end

		if not self.inventory[id] then
			return false
		end

		return self.inventory[id], self.inventory[id].qty
	end


	-- Update animation direction based on velocity.
	local function enterFrame()
		if instance._isRemoved or not instance.getLinearVelocity then
			return
		end

		local vx, vy = instance:getLinearVelocity()
		local newSequence

		-- 🔴 1. Attack state (highest priority)
		if instance.isAttacking then
			if not instance.attackDir then return end
			newSequence = "attack" .. instance.attackDir

		else
			-- 🟡 2. Just finished attack → force idle facing attack dir
			if string.find(instance.currentSequence, "attack") then
				newSequence = "idle" .. instance.attackDir
				instance.attackDir = nil
			end

			-- 🟢 3. Movement / idle logic
			if not newSequence then
				if math.abs(vx) > 3 or math.abs(vy) > 3 then
					if math.abs(vx) > math.abs(vy) then
						newSequence = vx < 0 and "walkWest" or "walkEast"
					else
						newSequence = vy < 0 and "walkNorth" or "walkSouth"
					end
				else
					local ivx = instance.inputVX or 0
					local ivy = instance.inputVY or 0

					if math.abs(ivx) > 0 or math.abs(ivy) > 0 then
						if math.abs(ivx) > math.abs(ivy) then
							newSequence = ivx < 0 and "idleWest" or "idleEast"
						else
							newSequence = ivy < 0 and "idleNorth" or "idleSouth"
						end
					else
						local current = instance.currentSequence or "idleSouth"
						newSequence = current:gsub("walk", "idle")

						if not newSequence:find("idle") then
							newSequence = "idleSouth"
						end
					end
				end
			end
		end

		if newSequence and newSequence ~= instance.currentSequence then
			instance.currentSequence = newSequence
			instance.sprite:setSequence(newSequence)
			instance.sprite:play()
		end
	end

	local function spriteListener( e )
		if e.phase == "loop" and string.find( instance.currentSequence, "attack" ) then
			-- instance.currentSequence = "idle" .. instance.attackDir 
			instance.isAttacking = false
		end
	end

	Runtime:addEventListener( "enterFrame", enterFrame )
	instance.sprite:addEventListener( "sprite", spriteListener )

	-- Cleanup on removal.
	function instance:finalize()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		Runtime:removeEventListener( "sprite", spriteListener )
	end
	instance:addEventListener( "finalize" )

	return instance
end

return M
