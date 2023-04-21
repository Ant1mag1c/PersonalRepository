local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local screen = require("Scripts.screen")

local dataHandler = require("Scripts.dataHandler")
local eventData = dataHandler.getData( "Data/events.tsv" )
local options = {}

local function chooseOption(event)
	local target = event.target
	if event.phase == "ended" then
		if title ~= "evil treasure" then
			print(event.target.id)
			composer.hideOverlay( "fade", 100 )
			-- print("hidden")

		end

		-- if title ~= "evil treasure" then
		-- 	if target == options[1] then
		-- 	-- Evil treasure tilanteessa pelaajalle tulee mahdollinen kirous
		-- 	print("You might be cursed")
		-- 	end
		-- end
	end
	return true
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	local sceneParams = event.params or {}
	local eventType = sceneParams.type
	print( "Luodaan tapahtuma: " .. eventType )
	local background = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width, screen.height )
	background:setFillColor(0, 0.5)

	local sceneLayer = display.newRect( sceneGroup, screen.centerX, screen.centerY, screen.width/1.3, screen.height/2 )
	sceneLayer:setFillColor(0.8, 0.8, 0.5)


	local title, description, image




	for k,v in pairs(sceneParams) do
		print( k, v )
	end

	-- Valitaan satunnainen tapahtuma, joka löytyy eventDatasta, ja luodaan sille näkymä.
	if sceneParams.type == "randomEvent" then
		local randomEvent = table.getRandom( eventData )
		table.print( randomEvent )
		title = randomEvent.title
		description = randomEvent.description
		image = randomEvent.image


		for i = 1,3 do
			local option = randomEvent["option" .. i]

			if option then
				options[#options + 1] = option
			end
		end

	-- Luodaan joku tietty tapahtuma, joka löytyy vain koodista, ja luodaan sille näkymä.
	else

		-- TODO: Koodaa title, description, image, options arvot
		if sceneParams.type == "sauna" then
			-- Saunassa pelaaja voisi healata itseään tai kasvataa max hp:ta X määrän

			title = "sauna"
			description = "You can feel the overwhelming feeling of relaxation and calmness"
			for i = 1, 2 do
				options[i] = i < 2 and "Heal for +50 sisu" or "Increase max sisu"
			end



		elseif sceneParams.type == "treasure" then
			-- Aarteita voisi olla erilaisia (esim Hyvä ja paha) math.randomilla
			-- Trasure lisää kortteja tai rahaa
			local r = math.random() < 1 and "normal" or "evil"

			if r == "normal" then
				title = "treasure"
				description = "You found a chest and are curious of what may you find from inside"
				for i = 1, 2 do
					options[i] = i < 2 and "Pick a new card" or "+30 money"
				end
			else
				sceneParams.type = "evil treasure"
				title = "evil treasure"
				description = "You found a chest with a dark glow around it"
				for i = 1, 2 do
					options[i] = i < 2 and "Open the chest" or "Leave the chest be"

				end

			end


			-- 	title = "shop"
			-- 	description = "You have entered a shop "
				-- print(sceneParams.isStore)


		else
			print("ERROR: Invalid scene type", sceneParams.type)
		end
	end

	local titleOptions =
	{
		text = title,
		x = sceneLayer.x,
		y = sceneLayer.y*0.6,
		width = sceneLayer.x*1.5,
		font = native.systemFont,
		fontSize = 25,
		align = "left"
	}

	local descriptionOptions =
	{
		text = description,
		x = sceneLayer.x,
		y =  sceneLayer.y*0.8,
		width = sceneLayer.x*1.5,
		font = native.systemFont,
		fontSize = 25,
		align = "left"

	}


	local titleText = display.newText( titleOptions )
	titleText:setFillColor( 1, 0, 0 )
	sceneGroup:insert(titleText)

	local descriptionText = display.newText( descriptionOptions )
	descriptionText:setFillColor( 1, 0, 0 )
	sceneGroup:insert(descriptionText)

	local imageWidth, imageHeight
	local imageX, imageY

	if title == "treasure" then
		imageWidth, imageHeight = 200*1.5, 400*1.5
		imageX, imageY = sceneLayer.x*0.45, sceneLayer.y*0.9

	elseif title == "sauna" then
		imageWidth, imageHeight = 200*0.7, 400*0.7
		imageX, imageY = sceneLayer.x*0.45, sceneLayer.y*1.2
	end

	local layerImage = display.newImageRect( sceneGroup, "Resources/Images/Levels/" .. title .. ".png", imageWidth, imageHeight )
	layerImage.x, layerImage.y = imageX, imageY


	-- local sceneText = display.newText( sceneGroup, title, screen.centerX, screen.centerY-125, native.systemFont, 40 )
	-- local infoText = display.newText( sceneGroup, description, screen.centerX, screen.centerY-50, native.systemFont, 50 )





	for i = 1, #options do
		local data = options[i]
		local text = display.newText( sceneGroup, options[i], screen.centerX, screen.centerY+(i*45), native.systemFont, 30 )
		text.id = options[i]
		text:addEventListener("touch", chooseOption)

	end

	-------------------------------------------------------

	-- Debuggaus nappula, jota käyttämällä voidaan palata karttaan.
	local debugButton = display.newText( sceneGroup, "Close Overlay", screen.minX + 10, screen.minY + 40, native.systemFont, 24 )
	debugButton.anchorX, debugButton.anchorY = 0, 0
	debugButton:setFillColor( 1, 0.9, 0 )

	debugButton:addEventListener( "touch", function(event)
		if event.phase == "ended" then
			composer.hideOverlay( "fade", 100 )
		end
		return true
	end )
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


function scene:destroy( event )
	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
