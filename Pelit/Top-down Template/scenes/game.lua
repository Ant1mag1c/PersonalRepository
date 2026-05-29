local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require( "classes.screen" )
local camera = require( "classes.camera" )
local loadsave = require( "classes.loadsave" )
local controls = require( "classes.controls" )
local saveManager = require( "classes.saveManager" )
local dialogHandler = require( "classes.dialogHandler" )
local pauseCreate = require( "widgets.pause" )
local ponytiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )
local debug = require( "classes.debug" )
local inventory = require( "classes.inventory" )
local assets = require( "data.assets" )
local stateHandler = require("data.stateHandler")

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )
-- physics.setDrawMode( "hybrid" )

---------------------------------------------------------------------------

-- Forward declarations & variables.
local groupLevel, groupUI

local player
local map
local mapName

local pauseMenu
local lastScreenshotFile

-- Forward declare so onKeyEvent can reference it.
local onMovementEvent, onKeyEvent, runDebug

local activeWindow
---------------------------------------------------------------------------

-- Functions.

-- Build the game state table for saving.
local function buildGameState()
	local state = { mapName = mapName }
	if player and not player._isRemoved then
		state.playerX = player.x
		state.playerY = player.y
		state.playerSequence = player.currentSequence
	end
	return state
end

-- Pause game-world simulation.
local function pauseGame()
	if player and not player._isRemoved then
		controls.stop()
		if player.stop then player:stop() end
		if player.sprite then player.sprite:pause() end
	end
	physics.pause()
	camera.stop()

	if debug.debugPrints then print( "controls stop called from main" ) end
end

-- Resume game-world simulation.
local function resumeGame()
	physics.start()
	physics.setGravity( 0, 0 )
	camera.start()
	
	if activeWindow then
		display.remove(activeWindow)
		activeWindow = nil
	end

	if player and not player._isRemoved then
		controls.start( onMovementEvent, onKeyEvent )
		
		if player.sprite then player.sprite:play() end
	end
end

local function closePauseMenu()
	if pauseMenu then
		pauseMenu:destroy()
		pauseMenu = nil
	end
end

-- Called when the player has pressed or let go of a registered keyboard key.
function onKeyEvent( action, phase )
	-- print( "onKeyEvent", action, phase )
	if action == "inventory" and phase == "down" then
		activeWindow = inventory:open( scene.overlayParams )
	end

	if string.find(action, "attack") and (phase == "down" or phase == "held") then
		if player and not player._isRemoved then
			local direction = action:sub(7):lower()
			player:attack( direction )
		end
	end
	if action == "interact" and phase == "down" then
		if player and not player._isRemoved then
			-- Determine facing direction from animation sequence.
			local seq = string.lower( player.currentSequence or "idleSouth" )
			local dirX, dirY = 0, 0
			if seq:find( "north" ) then dirY = -1
			elseif seq:find( "south" ) then dirY = 1
			elseif seq:find( "east" ) then dirX = 1
			elseif seq:find( "west" ) then dirX = -1
			end

			-- Cast a short ray from just past the player's collision radius.
			local px, py = player.x, player.y
			local startOffset = 2  -- pixels past player center to avoid self-hit
			local reach = 20       -- max interaction distance in pixels
			local fromX = px + dirX * startOffset
			local fromY = py + dirY * startOffset
			local toX = px + dirX * reach
			local toY = py + dirY * reach

			local hits = physics.rayCast( fromX, fromY, toX, toY, "sorted" )
			local found = false
			if hits then
				for i = 1, #hits do
					local obj = hits[i].object
					if obj and obj ~= player and obj.name ~= "hero" then
						-- print( "object: \"" .. tostring( obj.id ) .. "\" in front of player" )
						if obj.onAct then obj:onAct() end
						if obj.onReact and not obj.reacted then 
							obj:onReact() 
							obj.reacted = true 
						end
						
						found = true
						break
					end
				end
			end
			if not found then
				print( "no object in front of player" )
			end
		end

	elseif action == "menu" and phase == "down" then
		-- Capture screenshot of the screen while the game is still visible, in case the player goes to save their game.
		lastScreenshotFile = saveManager.captureScreenshot()

		-- Stop controls and pause game-world simulation while paused.
		controls.stop()
		pauseGame()

		-- Show the pause menu widget.
		pauseMenu = pauseCreate.new({
			onResume = function()
				closePauseMenu()
				resumeGame()
				controls.start( onMovementEvent, onKeyEvent )
			end,
			onSave = function()
				-- Show save screen as an overlay so the game scene stays alive.
				if pauseMenu then
					pauseMenu:disable()
				end
				composer.showOverlay( "scenes.load", {
					effect = "fade",
					time = 250,
					params = {
						mode = "save",
						gameState = buildGameState(),
						screenshotFile = lastScreenshotFile,
						isOverlay = true,
						onClose = function()
							if pauseMenu then
								pauseMenu:enable()
							end
						end,
					}
				})
			end,
			onLoad = function()
				-- Show load screen as an overlay so the pause menu stays visible behind it.
				if pauseMenu then
					pauseMenu:disable()
				end
				composer.showOverlay( "scenes.load", {
					effect = "fade",
					time = 250,
					params = {
						mode = "load",
						gameState = buildGameState(),
						isOverlay = true,
						onClose = function()
							if pauseMenu then
								pauseMenu:enable()
							end
						end,
					}
				})
			end,
			onOptions = function()
				-- Disable the pause widget (but keep it visible behind options).
				if pauseMenu then
					pauseMenu:disable()
				end
				composer.showOverlay( "scenes.options", {
					effect = "fade",
					time = 250,
					params = {
						onClose = function()
							if pauseMenu then
								pauseMenu:enable()
							end
						end,
					},
				})
			end,
			onQuit = function()
				closePauseMenu()
				composer.gotoScene( "scenes.menu", {
					effect = "fade",
					time = 500,
				})
			end,
		})
		scene.view:insert( pauseMenu )
	end

end

-- Called every frame while controls are active.
-- player:move() is defined in maps/extensions/hero.lua.
function onMovementEvent( vx, vy )
	if player and player.move and not player.isAttacking then
		player:move( vx, vy )
	end
end

---------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	groupLevel = display.newGroup()
	groupUI = display.newGroup()

	-- Create local references to passed parameters and prevent errors.
	local sceneParams = event.params or {}
	local launchParams = sceneParams.launchParams or {}

	mapName = sceneParams.mapName or "template"
	local mapFile = "maps/" .. mapName .. ".json"
	-- print( "mapName", mapName )
	-- print( "mapFile", mapFile )

	local mapData = json.decodeFile( system.pathForFile( mapFile, system.ResourceDirectory ) )
	map = ponytiled.new( mapData, "maps" )
	groupLevel:insert( map )

	-- Check for physics layer.
	local physicsLayer = map:findLayer("physics")
	if physicsLayer then
		physicsLayer.isVisible = false
	end


	-- Custom extensions (.lua files) for the map.
	map.extensions = "maps.extensions."
	map:extend( "hero")
	
	-- Hero needs to be created before other objects to prevent rally
	player = map:findObject( "hero" )

	-- Save player ref in gameState
	stateHandler.set("player", player)

	-- Move player and group refs to asset module
	assets.init( { player = player, groupUI = groupUI, groupLevel = groupLevel } )

	map:extend( "exit", "object" )

	-- Restore saved player position if loading a save.
	local savedState = sceneParams.savedState
	if savedState and player then
		if savedState.playerX then player.x = savedState.playerX end
		if savedState.playerY then player.y = savedState.playerY end
		if savedState.playerSequence and player.sprite then
			player.currentSequence = savedState.playerSequence
			player.sprite:setSequence( savedState.playerSequence )
			player.sprite:play()
		end
	end

	-- Set up camera to follow the player.
	camera.init( { { group = groupLevel, delta = 1 } } )

	-- Compute camera bounds from map pixel dimensions.
	local mapPixelW = mapData.width * mapData.tilewidth
	local mapPixelH = mapData.height * mapData.tileheight
	local halfScreenW = display.actualContentWidth * 0.5
	local halfScreenH = display.actualContentHeight * 0.5

	local boundsXMin = halfScreenW
	local boundsXMax = mapPixelW - halfScreenW
	local boundsYMin = halfScreenH
	local boundsYMax = mapPixelH - halfScreenH

	-- If the map is smaller than the screen on an axis, center it.
	if boundsXMin > boundsXMax then
		boundsXMin = mapPixelW * 0.5
		boundsXMax = boundsXMin
	end
	if boundsYMin > boundsYMax then
		boundsYMin = mapPixelH * 0.5
		boundsYMax = boundsYMin
	end

	camera.setBounds( { xMin = boundsXMin, yMin = boundsYMin, xMax = boundsXMax, yMax = boundsYMax } )

	if player then
		camera.setTarget( player, { smoothing = 0.3 } )
		camera.snapToTarget()
	end

	local dialogFrame = dialogHandler.newFrame( groupUI)

	-- Give scene default params to use on inventory and crafting
	if not scene.overlayParams then
		scene.overlayParams = { 
			parent = groupUI,
			player = player,
			onPause = pauseGame,
			onResume = resumeGame,
		}
	end

	sceneGroup:insert( groupLevel )
	sceneGroup:insert( groupUI )
end

---------------------------------------------------------------------------

function scene:show( event )
	local sceneGroup = self.view

	-- Create local references to passed parameters and prevent errors.
	local sceneParams = event.params or {}
	local launchParams = sceneParams.launchParams or {}


	if event.phase == "will" then
		-- If coming from launchScreen scene, then start by removing it.
		if composer._previousScene == "scenes.launchScreen" then
			composer.removeScene( "scenes.launchScreen" )
		end

	elseif event.phase == "did" then
		physics.start()
		physics.setGravity( 0, 0 )
		controls.start( onMovementEvent, onKeyEvent )
		camera.start()

	end
end

---------------------------------------------------------------------------

timer.performWithDelay( 5, function ()
	debug:newButton(groupUI)
end )


---------------------------------------------------------------------------

function scene:hide( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		closePauseMenu()
		camera.stop()
		controls.stop()
		if player and player.stop then
			player:stop()
		end

	elseif event.phase == "did" then


	end
end

---------------------------------------------------------------------------

function scene:destroy( event )
	player = nil
	map = nil
end

---------------------------------------------------------------------------

-- Called when a composer overlay (e.g. options, save, load) is hidden.
-- Each overlay re-enables the pause menu via its own onClose callback,
-- so this handler only needs to resume the game if the pause menu was closed.
function scene:overlayEnded( event )
	if not pauseMenu then
		resumeGame()
		controls.start( onMovementEvent, onKeyEvent )
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
scene:addEventListener( "overlayEnded", scene )

---------------------------------------------------------------------------

return scene
