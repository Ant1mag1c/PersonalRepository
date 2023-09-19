local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local settings = require("Scripts.settings")
local screen = require("Scripts.screen")
local widget = require("widget")

local scrollSpeed = 15000
local scrollView

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view


	local background = display.newImage(sceneGroup, "Resources/Images/bgSketch3333.jpg")
	background.x, background.y = display.contentCenterX, display.contentCenterY
	display.scaleDisplayObject( background, screen.width, screen.height )


	local logoWidth = 400
	local logoHeight = 621 / 1904 * logoWidth
    local logo = display.newImageRect( sceneGroup, "Resources/Images/sisuvalalogo3.png", logoWidth, logoHeight )
	logo.x, logo.y = display.contentCenterX, screen.minY + logoHeight/2 + 10


	local function onButtonEvent(event)
		if event.phase == "ended" then
			local target = event.target

			if target.id == "back" then
				composer.gotoScene("scenes.mainMenu",{
					time = 250,
					effect = "fade"
				})
			end
		end
		return true
	end


	local buttonBack = widget.newButton({
		width = 200,
		height = 458/1141*200,
		defaultFile = "Resources/Images/backbutton1.png",
		overFile = "Resources/Images/backbutton.png",
		id = "back",
		label = "Back",
		labelColor = { default={ 0.9 }, over={ 1 } },
		onEvent = onButtonEvent,
		font = settings.userdata.font,
		fontSize = 22,
	})
	sceneGroup:insert( buttonBack )
	buttonBack.x, buttonBack.y = screen.minX + 100, screen.minY + 50

	-- Luodaan scrollattava tekstikenttä, joka lähtee automaattisesti rullaamaan alaspäin.
	local scrollWidth = 400
	scrollView = widget.newScrollView(
		{
			top = logo.y + logoHeight/2,
			left = (display.contentWidth - scrollWidth)*0.5,
			width = scrollWidth,
			height = 420,
			scrollWidth = 600,
			scrollHeight = 800,
			backgroundColor = { 0, 0.8 },
		}
	)
	sceneGroup:insert( scrollView )

	-- Tekijöiden nimet ja roolit.
	local credits = {
		{ "" },
		{ "ROSO GAMES 2022", 1 },
		{ ""},
		{ ""},

		{ "PROGRAMMING", 2 },
		{ "Teemu Hägerth" },
		{ "Vilma Iso-Ikala" },
		{ "Jyry Niemitalo" },
		{ "Riia Hyttinen" },
		{ "" },

		{ "DESIGN", 2 },
		{ "Robert Santala" },
		{ "Teemu Hägerth" },
		{ "Jyry Niemitalo" },
		{ "Lyly-Petteri Heikkilä" },
		{ "Jari Ruotsalainen" },
		{ "Kadir Özoglu" },
		{ "" },

		{ "ART", 2 },
		{ "Lyly-Petteri Heikkilä" },
		{ "Emma Julkunen" },
		{ "Jyry Niemitalo" },
		{ "" },

		{ "MUSIC & SFX (WIP)", 2 },
		{ "Monika Van Wonterghem" },
		{ "Topi Sunila" },
		{ "" },

		{ "OBSERVING", 2 },
		{ "Laura Hyvärinen" },
		{ "" },

		{ "ROSO GAMES LEAD", 2 },
		{ "Eetu Rantanen" },
		{ "" },
		{ "" },
		{ "" },
	}

	-- Lisätään tekstit yläpuolelta scrollattavaan tekstikenttään.
	local text = {}
	local maxY = 0

	for i = 1, #credits do

		local fontSize = 24

		local style = credits[i][2]
		if style then
			if style == 1 then
				fontSize = 32
			elseif style == 2 then
				fontSize = 28
			end
		end

		text[i] = display.newText({
			parent = scrollView,
			text = credits[i][1],
			width = scrollWidth,
			align = "center",
			font = settings.userdata.font,
			fontSize = fontSize,
			x = scrollWidth*0.5,
			y = i*30,
		})

		if style then
			text[i]:setFillColor( 80/255, 218/255, 169/255 )
		end

		scrollView:insert(text[i])
		maxY = text[i].y + text[i].height*0.5

	end

	local kukunoriText = display.newText({
		parent = scrollView,
		text = "PRODUCED BY",
		width = scrollWidth,
		align = "center",
		font = settings.userdata.font,
		fontSize = 32,
		x = scrollWidth*0.5,
		y = maxY,
	})
	kukunoriText:setFillColor( 80/255, 218/255, 169/255 )
	scrollView:insert(kukunoriText)

	local kukunoriLogo = display.newImage( "Resources/Images/Kukunori_vaaka_white.png", scrollWidth*0.5, kukunoriText.y + kukunoriText.height )
	kukunoriLogo:scale(0.25, 0.25)
	scrollView:insert(kukunoriLogo)


	local skrText = display.newText({
		parent = scrollView,
		text = "FUNDED BY",
		width = scrollWidth,
		align = "center",
		font = settings.userdata.font,
		fontSize = 32,
		x = scrollWidth*0.5,
		y = kukunoriLogo.y + kukunoriLogo.height*0.5*kukunoriLogo.yScale + 50,
	})
	skrText:setFillColor( 80/255, 218/255, 169/255 )
	scrollView:insert(skrText)

	local skrLogo = display.newImage( "Resources/Images/skr-nega-logo-png.png" )
	skrLogo.x = scrollWidth*0.5
	skrLogo.y = skrText.y + skrText.height*0.5 + skrLogo.height*0.5*skrLogo.yScale - 240
	skrLogo:scale(0.25, 0.25)
	scrollView:insert(skrLogo)

	-- Lisätään perään näkymätön kuva, jotta pohjaan saadaan tyhjää scrollattavaa tilaa.
	local emptyPadding = display.newImage( "Resources/Images/skr-nega-logo-png.png" )
	emptyPadding.x = scrollWidth*0.5
	emptyPadding.y = skrLogo.y + skrLogo.height*0.5 - 280
	emptyPadding.alpha = 0
	emptyPadding:scale(0.25, 0.25)
	scrollView:insert(emptyPadding)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		scrollView:scrollTo( "bottom", { time=scrollSpeed } )
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