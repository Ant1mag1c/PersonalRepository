local composer = require("composer")
local scene = composer.newScene()

---------------------------------------------------------------------------

-- Common plugins, modules, libraries & classes.
local screen = require( "classes.screen" )
local loadsave = require( "classes.loadsave" )
local widget = require( "widget" )

---------------------------------------------------------------------------

-- Forward declarations & variables.

local menuButton = {}

---------------------------------------------------------------------------

-- Functions.

-- Function to handle button events
local function menuListener( event )
	if event.phase == "ended" then
		local id = event.target.id
		-- print( id )

		if id == "play" or id == "load" or id == "credits" then
			local sceneName
			local params
			if id == "play" then
				sceneName = "game"
			elseif id == "load" then
				sceneName = "load"
				params = { mode = "load" }
			else
				sceneName = id
			end
			composer.gotoScene( "scenes." .. sceneName, { effect = "fade", time = 500, params = params } )

		elseif id == "options" then
			composer.showOverlay( "scenes.options", {
				effect = "fade",
				time = 250
			} )

		elseif id == "exit" then
			native.requestExit()

		end
	end
	return true
end

---------------------------------------------------------------------------

function scene:create( event )
	local sceneGroup = self.view

	-- Create local references to passed parameters and prevent errors.
	local sceneParams = event.params or {}
	local launchParams = sceneParams.launchParams or {}

	-----------------------------------------------------------------------
	-- Create background image to fill the screen

	local background = display.newImage(
		sceneGroup, "assets/images/ui/menu.png",
		screen.centerX,
		screen.centerY
	)

    if background then
        display.scaleDisplayObject( background, screen.width, screen.height )
    end

	-----------------------------------------------------------------------
	-- Create menu buttons using a data table. To add or remove buttons,
	-- edit the buttonData table below. Each entry needs an id and label.

	local buttonData = {
		{ id = "play",    label = "Play" },
		{ id = "load",    label = "Load" },
		{ id = "options", label = "Options" },
		{ id = "credits", label = "Credits" },
		{ id = "exit",    label = "Exit" },
	}

	local spacing = 6
	local prevButton = nil

	for _, data in ipairs( buttonData ) do
		menuButton[data.id] = widget.newButton(
			{
				x = screen.centerX,
				y = prevButton and (prevButton.y + prevButton.height + spacing) or (screen.centerY + spacing),
				id = data.id,
				label = data.label,
				labelAlign = "center",
				labelColor = { default={ 0.9 }, over={ 1 } },
				onEvent = menuListener,
				width = 80,
				height = 26,
				fontSize = 16,
				font = native.systemFontBold,
				shape = "rect",
				fillColor = { default={ 0, 0.7 }, over={ 0, 0.9 } },
				isEnabled = false,
			}
		)
		sceneGroup:insert( menuButton[data.id] )
		prevButton = menuButton[data.id]
	end

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
		for _, button in pairs( menuButton ) do
			button:setEnabled( true )
		end


	end
end

---------------------------------------------------------------------------

function scene:hide( event )
	local sceneGroup = self.view

	if event.phase == "will" then
		for _, button in pairs( menuButton ) do
			button:setEnabled( false )
		end


	elseif event.phase == "did" then


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