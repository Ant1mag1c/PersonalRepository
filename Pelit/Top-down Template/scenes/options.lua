local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require( "classes.screen" )
local loadsave = require( "classes.loadsave" )
local controls = require( "classes.controls" )
local widget = require( "widget" )

---------------------------------------------------------------------------

-- Forward declarations & variables.
local buttonBack
local onClose
local audioGroup, controlsGroup
local underlineAudio, underlineControls
local keySlotButtons = {}
local captureGroup, captureKeyListener

local sliderOptions = {
	frames = {
		{ x=0, y=0, width=18, height=32 },
		{ x=20, y=0, width=18, height=32 },
		{ x=40, y=0, width=18, height=32 },
		{ x=62, y=0, width=18, height=32 },
		{ x=84, y=0, width=32, height=32 }
	},
	sheetContentWidth = 116,
	sheetContentHeight = 32
}
local sliderSheet = graphics.newImageSheet( "assets/images/ui/slider.png", sliderOptions )

---------------------------------------------------------------------------

-- Key name display formatting.

local keyDisplayNames = {
	["left"] = "LEFT",
	["right"] = "RIGHT",
	["up"] = "UP",
	["down"] = "DOWN",
	["space"] = "SPACE",
	["enter"] = "ENTER",
	["escape"] = "ESC",
	["tab"] = "TAB",
	["deleteBack"] = "BKSP",
	["deleteForward"] = "DEL",
	["leftShift"] = "L-SHIFT",
	["rightShift"] = "R-SHIFT",
	["leftControl"] = "L-CTRL",
	["rightControl"] = "R-CTRL",
	["leftAlt"] = "L-ALT",
	["rightAlt"] = "R-ALT",
}

local function formatKeyName( keyName )
	return keyDisplayNames[keyName] or string.upper( keyName )
end

---------------------------------------------------------------------------

-- Action order and labels for the controls tab.

local actionOrder = { "up", "down", "left", "right", "interact", "menu" }
local actionLabels = {
	up = "Up",
	down = "Down",
	left = "Left",
	right = "Right",
	interact = "Interact",
	menu = "Menu",
}

---------------------------------------------------------------------------

-- Functions.

local function switchTab( tabName )
	audioGroup.isVisible = (tabName == "audio")
	controlsGroup.isVisible = (tabName == "controls")
	underlineAudio.isVisible = (tabName == "audio")
	underlineControls.isVisible = (tabName == "controls")
end


local function refreshKeySlotLabels()
	local bindings = loadsave.userdata.controls
	for action, btns in pairs( keySlotButtons ) do
		local keys = bindings[action] or {}
		for slot = 1, 2 do
			local keyName = keys[slot]
			local displayText = keyName and formatKeyName( keyName ) or "---"
			btns[slot]:setLabel( displayText )
		end
	end
end


local function cancelKeyCapture()
	if captureKeyListener then
		Runtime:removeEventListener( "key", captureKeyListener )
		captureKeyListener = nil
	end
	if captureGroup then
		display.remove( captureGroup )
		captureGroup = nil
	end
end


local function applyKeyBinding( action, slotIndex, newKey )
	local bindings = loadsave.userdata.controls

	-- If the same key is already in this exact slot, clear it (toggle off).
	if bindings[action] and bindings[action][slotIndex] == newKey then
		bindings[action][slotIndex] = nil
	else
		-- Remove this key from any other action/slot to prevent conflicts.
		for _, keys in pairs( bindings ) do
			for i = 1, 2 do
				if keys[i] == newKey then
					keys[i] = nil
				end
			end
		end

		-- Assign the new key.
		bindings[action] = bindings[action] or {}
		bindings[action][slotIndex] = newKey
	end

	-- Persist, rebuild key map, and refresh UI.
	loadsave.save( loadsave.userdata, "userdata.json" )
	controls.rebuildKeyMap()
	refreshKeySlotLabels()
end


local function startKeyCapture( action, slotIndex )
	if captureGroup then return end

	captureGroup = display.newGroup()
	scene.view:insert( captureGroup )

	-- Semi-transparent backdrop.
	local backdrop = display.newRect(
		captureGroup,
		screen.centerX, screen.centerY,
		screen.width, screen.height
	)
	backdrop:setFillColor( 0, 0.7 )

	-- Instruction text.
	display.newText({
		parent = captureGroup,
		text = "Press a key for \"" .. actionLabels[action] .. "\"",
		fontSize = 14,
		font = native.systemFontBold,
		x = screen.centerX,
		y = screen.centerY - 10,
		width = 250,
		align = "center",
	})

	local cancelText = display.newText({
		parent = captureGroup,
		text = "Tap outside to cancel",
		fontSize = 10,
		font = native.systemFont,
		x = screen.centerX,
		y = screen.centerY + 14,
	})
	cancelText:setFillColor( 0.6 )

	-- Cancel on tap.
	backdrop:addEventListener( "touch", function()
		if event.phase == "ended" then
			cancelKeyCapture()
		end
		return true
	end )
	backdrop:addEventListener( "touch", function() return true end )

	-- Capture the next key press.
	captureKeyListener = function( event )
		if event.phase == "down" then
			applyKeyBinding( action, slotIndex, event.keyName )
			cancelKeyCapture()
		end
		return true
	end
	Runtime:addEventListener( "key", captureKeyListener )
end


local function resetControlsToDefaults()
	local defaults = require( "data.defaultSettings" )
	local defaultControls = defaults.controls

	for action, keys in pairs( defaultControls ) do
		loadsave.userdata.controls[action] = {}
		for i = 1, math.min( 2, #keys ) do
			loadsave.userdata.controls[action][i] = keys[i]
		end
	end

	loadsave.save( loadsave.userdata, "userdata.json" )
	controls.rebuildKeyMap()
	refreshKeySlotLabels()
end


local function buttonEvent( event )
	if event.phase == "ended" then
		local id = event.target.id
		print( "Button pressed:", id )

		if id == "back" then
			composer.hideOverlay( "fade", 250 )

		end
	end
end


local function sliderListener( event )
	if event.phase == "ended" then
		local id = event.target.id
		print( "Slider \"" .. id .. "\" at " .. event.value .. "%" )

		loadsave.userdata.audio.volume[event.target.id] = event.value
		loadsave.save( loadsave.userdata, "userdata.json" )

		if id == "master" then
			audio.setVolume( event.value / 100 )
		else
			audio.setVolume( event.value / 100, id )
		end
	end
end


local function switchPress( event )
	local switch = event.target
	print( "Switch \"" .. switch.id .. "\" is on:", tostring(switch.isOn) )

	loadsave.userdata["fullscreen"] = switch.isOn
	loadsave.save( loadsave.userdata, "userdata.json" )

	if switch.isOn then
		native.setProperty( "windowMode", "fullscreen" )
	else
		native.setProperty( "windowMode", "normal" )
	end
end

---------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-----------------------------------------------------------------------
	-- Create background and window.

	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor( 0, 0.5 )
	background:addEventListener( "touch", function() return true end )
	background:addEventListener( "tap", function() return true end )

	local window = display.newRect( sceneGroup, screen.centerX, screen.centerY, 300, 300 )
	window:setFillColor( 0, 0.9 )

	-----------------------------------------------------------------------
	-- Create title text.

	local title = display.newText({
		parent = sceneGroup,
		text = "Options",
		fontSize = 20,
		font = native.systemFontBold,
	})
	title.x = screen.centerX
	title.y = window.y - window.height*0.5 + title.height*0.5 + 10

	-----------------------------------------------------------------------
	-- Create tab buttons.

	local tabY = title.y + title.height*0.5 + 16
	local tabWidth = 100
	local tabSpacing = 4
	local tabHeight = 20

	local tabAudioX = screen.centerX - tabWidth*0.5 - tabSpacing*0.5
	local tabControlsX = screen.centerX + tabWidth*0.5 + tabSpacing*0.5

	local tabAudioBtn = widget.newButton({
		x = tabAudioX,
		y = tabY,
		width = tabWidth,
		height = tabHeight,
		label = "Audio",
		labelAlign = "center",
		fontSize = 11,
		font = native.systemFontBold,
		labelColor = { default={ 0.9 }, over={ 1 } },
		shape = "rect",
		fillColor = { default={ 0.1, 0.1, 0.15 }, over={ 0.15, 0.15, 0.2 } },
		onEvent = function( e )
			if e.phase == "ended" then switchTab( "audio" ) end
			return true
		end,
	})
	sceneGroup:insert( tabAudioBtn )

	local tabControlsBtn = widget.newButton({
		x = tabControlsX,
		y = tabY,
		width = tabWidth,
		height = tabHeight,
		label = "Controls",
		labelAlign = "center",
		fontSize = 11,
		font = native.systemFontBold,
		labelColor = { default={ 0.9 }, over={ 1 } },
		shape = "rect",
		fillColor = { default={ 0.1, 0.1, 0.15 }, over={ 0.15, 0.15, 0.2 } },
		onEvent = function( e )
			if e.phase == "ended" then switchTab( "controls" ) end
			return true
		end,
	})
	sceneGroup:insert( tabControlsBtn )

	-- Tab underline indicators.
	underlineAudio = display.newRect( sceneGroup, tabAudioX, tabY + tabHeight*0.5 + 2, tabWidth - 4, 2 )
	underlineAudio:setFillColor( 0.8, 0.8, 1 )

	underlineControls = display.newRect( sceneGroup, tabControlsX, tabY + tabHeight*0.5 + 2, tabWidth - 4, 2 )
	underlineControls:setFillColor( 0.8, 0.8, 1 )
	underlineControls.isVisible = false

	local contentTopY = tabY + tabHeight*0.5 + 8

	-----------------------------------------------------------------------
	-- Audio tab content.

	audioGroup = display.newGroup()
	sceneGroup:insert( audioGroup )

	local volume = loadsave.userdata.audio.volume

	local sliderMasterVolume = widget.newSlider({
		sheet = sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		fillFrame = 4,
		handleFrame = 5,
		frameWidth = 8,
		frameHeight = 16,
		handleWidth = 16,
		handleHeight = 16,
		x = screen.centerX,
		y = contentTopY + 26,
		width = 160,
		id = "master",
		value = volume["master"],
		listener = sliderListener
	})
	audioGroup:insert( sliderMasterVolume )

	local titleMasterVolume = display.newText({
		parent = audioGroup,
		text = "Master Volume",
		fontSize = 12,
		font = native.systemFontBold,
	})
	titleMasterVolume.x = screen.centerX
	titleMasterVolume.y = sliderMasterVolume.y - sliderMasterVolume.height*0.5 - 4


	local sliderMusicVolume = widget.newSlider({
		sheet = sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		fillFrame = 4,
		handleFrame = 5,
		frameWidth = 8,
		frameHeight = 16,
		handleWidth = 16,
		handleHeight = 16,
		x = screen.centerX,
		y = sliderMasterVolume.y + sliderMasterVolume.height + 32,
		width = 160,
		id = "music",
		value = volume["music"],
		listener = sliderListener
	})
	audioGroup:insert( sliderMusicVolume )

	local titleMusicVolume = display.newText({
		parent = audioGroup,
		text = "Music Volume",
		fontSize = 12,
		font = native.systemFontBold,
	})
	titleMusicVolume.x = screen.centerX
	titleMusicVolume.y = sliderMusicVolume.y - sliderMusicVolume.height*0.5 - 4


	local sliderSFXVolume = widget.newSlider({
		sheet = sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		fillFrame = 4,
		handleFrame = 5,
		frameWidth = 8,
		frameHeight = 16,
		handleWidth = 16,
		handleHeight = 16,
		x = screen.centerX,
		y = sliderMusicVolume.y + sliderMusicVolume.height + 32,
		width = 160,
		id = "sfx",
		value = volume["sfx"],
		listener = sliderListener
	})
	audioGroup:insert( sliderSFXVolume )

	local titleSFXVolume = display.newText({
		parent = audioGroup,
		text = "SFX Volume",
		fontSize = 12,
		font = native.systemFontBold,
	})
	titleSFXVolume.x = screen.centerX
	titleSFXVolume.y = sliderSFXVolume.y - sliderSFXVolume.height*0.5 - 4


	-----------------------------------------------------------------------
	-- Fullscreen checkbox.

	local fullscreenCheckbox = widget.newSwitch({
		x = window.x + 42,
		y = sliderSFXVolume.y + sliderSFXVolume.height + 24,
		width = 20,
		height = 20,
		style = "checkbox",
		id = "fullscreen",
		onPress = switchPress,
		initialSwitchState = loadsave.userdata["fullscreen"],
	})
	audioGroup:insert( fullscreenCheckbox )

	local titleFullscreen = display.newText({
		parent = audioGroup,
		text = "Fullscreen",
		fontSize = 12,
		font = native.systemFontBold,
	})
	titleFullscreen.anchorX = 1
	titleFullscreen.x = fullscreenCheckbox.x - fullscreenCheckbox.width - titleFullscreen.width*0.5 - 10
	titleFullscreen.y = fullscreenCheckbox.y

	-----------------------------------------------------------------------
	-- Controls tab content.

	controlsGroup = display.newGroup()
	sceneGroup:insert( controlsGroup )
	controlsGroup.isVisible = false

	-- Normalize bindings to 2 slots max.
	for _, keys in pairs( loadsave.userdata.controls ) do
		for i = #keys, 3, -1 do
			keys[i] = nil
		end
	end

	-- Column positions.
	local labelX = 105
	local slot1X = 270
	local slot2X = 340
	local slotWidth = 54
	local slotHeight = 18

	-- Column headers.
	local headerKey1 = display.newText({
		parent = controlsGroup,
		text = "Key 1",
		fontSize = 9,
		font = native.systemFont,
		x = slot1X,
		y = contentTopY + 6,
	})
	headerKey1:setFillColor( 0.6 )

	local headerKey2 = display.newText({
		parent = controlsGroup,
		text = "Key 2",
		fontSize = 9,
		font = native.systemFont,
		x = slot2X,
		y = contentTopY + 6,
	})
	headerKey2:setFillColor( 0.6 )

	-- Action rows.
	local rowStartY = contentTopY + 20
	local rowSpacing = 26

	keySlotButtons = {}

	for i, action in ipairs( actionOrder ) do
		local rowY = rowStartY + (i - 1) * rowSpacing
		local bindings = loadsave.userdata.controls[action] or {}

		-- Action label.
		local label = display.newText({
			parent = controlsGroup,
			text = actionLabels[action],
			fontSize = 11,
			font = native.systemFontBold,
			x = labelX,
			y = rowY,
		})
		label.anchorX = 0

		-- Key slot buttons.
		keySlotButtons[action] = {}
		for slot = 1, 2 do
			local keyName = bindings[slot]
			local displayText = keyName and formatKeyName( keyName ) or "---"

			local btn = widget.newButton({
				x = (slot == 1) and slot1X or slot2X,
				y = rowY,
				width = slotWidth,
				height = slotHeight,
				label = displayText,
				labelAlign = "center",
				fontSize = 10,
				font = native.systemFont,
				labelColor = { default={ 0.9 }, over={ 1 } },
				shape = "rect",
				fillColor = { default={ 0.15, 0.15, 0.2 }, over={ 0.25, 0.25, 0.3 } },
				id = action .. "_" .. slot,
				onEvent = function( e )
					if e.phase == "ended" then
						startKeyCapture( action, slot )
					end
					return true
				end,
			})
			controlsGroup:insert( btn )
			keySlotButtons[action][slot] = btn
		end
	end

	-- Reset to Defaults button.
	local resetY = rowStartY + #actionOrder * rowSpacing + 8

	local resetBtn = widget.newButton({
		x = screen.centerX,
		y = resetY,
		width = 130,
		height = 22,
		label = "Reset to Defaults",
		labelAlign = "center",
		fontSize = 10,
		font = native.systemFontBold,
		labelColor = { default={ 0.9, 0.6, 0.6 }, over={ 1, 0.7, 0.7 } },
		shape = "rect",
		fillColor = { default={ 0.3, 0.1, 0.1 }, over={ 0.4, 0.15, 0.15 } },
		id = "resetControls",
		onEvent = function( e )
			if e.phase == "ended" then
				resetControlsToDefaults()
			end
			return true
		end,
	})
	controlsGroup:insert( resetBtn )

	-----------------------------------------------------------------------
	-- Create back button.

	buttonBack = widget.newButton({
		x = screen.centerX,
		y = window.y + window.height*0.5 - 16,
		id = "back",
		label = "Back",
		labelAlign = "center",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = buttonEvent,
		width = 100,
		height = 30,
		fontSize = 14,
		font = native.systemFontBold,
		shape = "rect",
		fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
		isEnabled = false,
	})
	sceneGroup:insert( buttonBack )

end

---------------------------------------------------------------------------

function scene:show( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		local params = event.params or {}
		onClose = params.onClose

	elseif event.phase == "did" then
		buttonBack:setEnabled( true )

	end
end

---------------------------------------------------------------------------

function scene:hide( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		cancelKeyCapture()
		buttonBack:setEnabled( false )

	elseif event.phase == "did" then
		if onClose then
			onClose()
			onClose = nil
		end
	end
end

---------------------------------------------------------------------------

function scene:destroy( event )


end

---------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------

return scene
