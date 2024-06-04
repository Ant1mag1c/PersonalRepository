local controls = {}

-- Hiiren debug UI:n piirtäminen.
-- local debugMouse = true

local playerRef = nil
local callbackMovement = nil
local hasStarted = false
local isPressed = {}
local key = {}


-- Lokalisoidaan useasti käytetyt matikka funktiot.
local atan2 = math.atan2
local deg = math.deg
local cos = math.cos
local sin = math.sin

----------------------------------------------------------------------------------------------------
-- Näppäin-kontrollit:

-- Pidetään liikkumisnapit omassa taulukossa, jotta ne voidaan
-- helposti erottaa muista napeista onKeyEvent funktiossa.
local moveKey = {
	["left"] = true,
	["right"] = true,
	["up"] = true,
	["down"] = true,
}

-- Tarkkaile mitkä liikkumiskontrollit pelaaja on painanut alas.
local function monitorControls()
	local vx, vy = 0, 0

	if isPressed["left"] then
		vx = vx - 1
	end

	if isPressed["right"] then
		vx = vx + 1
	end

	if isPressed["up"] then
		vy = vy - 1
	end

	if isPressed["down"] then
		vy = vy + 1
	end

	-- Lasketaan liikkuminen x ja y liikkumisvektoreista (radiaaneissa):
	local angle = atan2( vy, vx )
	-- Huom! math.cos ja math.sin palauttavaa arvon -1 ja 1 väliltä, mutta jos vx tai vy on 0, niin
	-- silloin Luan käyttämä double-precesion floating point luku saattaa antaa pyöristysvirheen ja
	-- tämä johtaa hahmon virheelliseen liikkumiseen ja animointiin. Tämän takia tarkistetaan, että
	-- jos vx tai vy on 0, niin silloin x ja y arvoksi laitetaan 0:
	local x = vx == 0 and 0 or cos( angle )
	local y = vy == 0 and 0 or sin( angle )

	callbackMovement( x, y )
end

-- Kontrolloi mitä tapahtuu, kun pelaaja painaa mitä tahansa näppäintä.
local function onKeyEvent(event)
	local keyName = key[event.keyName]

	-- Jos näppäintä ei ole määritetty pelin asetuksissa, niin älä tee mitään.
	if keyName then
		isPressed[keyName] = event.phase == "down"

		-- Älä kutsu callbackia, jos kyseessä on liikkumisnappi.
		if not moveKey[keyName] then
			-- print( "onKeyEvent - controls:", keyName, event.phase )
			playerRef.action( keyName, event.phase )
		end
	end
end

----------------------------------------------------------------------------------------------------
-- Hiiri-kontrollit:
local dx, dy

-- Hiiren debuggaamiseen käytettävät muuttujat ja funktiot:
local mouseAim, mouseNW2SE, mouseSW2NE
local debugLineLength = 200

local function updateMouseUI()
	local playerX, playerY = playerRef:localToContent( 0, 0 )

	-- Tuhotaan ja luodaan uudestaan hiireen liittyvät debug UI elementit:
	display.remove( mouseAim )
	display.remove( mouseNW2SE )
	display.remove( mouseSW2NE )

	mouseAim = display.newLine( playerX, playerY, playerX + dx, playerY + dy )
	mouseNW2SE = display.newLine( playerX - debugLineLength, playerY - debugLineLength, playerX + debugLineLength, playerY + debugLineLength )
	mouseSW2NE = display.newLine( playerX - debugLineLength, playerY + debugLineLength, playerX + debugLineLength, playerY - debugLineLength )
end


-- Tarkastelee hiiren toiminnot
local function onMouseEvent( event )
	dx, dy = playerRef:contentToLocal( event.x, event.y )

    local angleInRad = atan2( dy, dx )
    local angle = deg( angleInRad )

	local isMouseButtonDown = event.isPrimaryButtonDown or event.isSecondaryButtonDown or event.isMiddleButtonDown
	local eventType = event.type

	-- Tallennetaan muissa tiedostoissakin tarvittavia muuttujia suoraan pelaajahahmoon,
	-- niin näitä arvoja ei tarvitse laskea muissa tiedostoissa uudestaan.
	playerRef.isMouseButtonDown = isMouseButtonDown
	playerRef._angleInRad = angleInRad
	playerRef._angle = angle
	playerRef._dx = dx
	playerRef._dy = dy

	-- Katsotaan painetaanko jotain hiiren nappia alas tai liikutetaanko hiirtä napin ollessa painettuna.
	if eventType == "down" or eventType == "drag" then
		if isMouseButtonDown then

			-- Tarkastetaan missä kulmassa hiiri on suhteessa pelaajaan.
			local direction
			if ( -135 >= angle or angle > 135 ) then
				direction = "Left"
			elseif ( -45 < angle and angle <= 45 ) then
				direction = "Right"
			elseif ( -135 < angle and angle <= -45 ) then
				direction = "Up"
			elseif ( 135 >= angle and angle > 45 ) then
				direction = "Down"
			end

            -- Pelaaja hyökkää kaikista hiiren päänäppäimistä.
			-- TODO: pitäisikö pelaajan hyökkäys ja/tai katselu päivittää toimimaan vain jos hiiren painaa alas, ei jos hiirtä vedetään?
            playerRef.action( playerRef.weapon, eventType )

			-- Päivitä pelaajan suuntaa vain jos se on muuttunut.
			if direction ~= playerRef.direction then
				playerRef.look( direction, true )
			end

		end
	end
end

----------------------------------------------------------------------------------------------------
-- Moduulin avoimet funktiot:

-- Haetaan käyttäjän määrittelemät kontrollit muokataaan ne "koodiystävällisempään" muotoon.
-- (Huom! Käytetään funktiota, jotta kontrollit voidaan päivittää haluttaessa pelin aikana.)
function controls.updateKeys()
	local loadsave = require( "scripts.loadsave" )

	-- k = key/avain, v = value/arvo.
	for k, v in pairs( loadsave.userdata.controls ) do
		-- Looppi käy läpi kaikki v:n arvot.
		for i = 1, #v do
			-- Taulukkoon kirjoitetaan käyttäjän valitsemat painikkeet(v[i]) ja niiden toiminnot(k).
			key[v[i]] = k
		end
	end

	-- Palautetaan key taulukko, jotta sitä voidaan myös käyttää muissa tiedostoissa.
	return key
end


function controls.start( player )
    if not hasStarted then
        hasStarted = true
		controls.updateKeys()

		playerRef = player
        callbackMovement = player.move

        Runtime:addEventListener("enterFrame", monitorControls)
        Runtime:addEventListener("key", onKeyEvent)
        Runtime:addEventListener("mouse", onMouseEvent )

		if debugMouse then
			Runtime:addEventListener( "enterFrame", updateMouseUI )
		end
    end
end


function controls.stop()
    if hasStarted then
        hasStarted = false

        Runtime:removeEventListener("enterFrame", monitorControls)
        Runtime:removeEventListener("key", onKeyEvent)
        Runtime:removeEventListener("mouse", onMouseEvent)

		if debugMouse then
			Runtime:removeEventListener( "enterFrame", updateMouseUI )
		end

		-- Varmistetaan ettei mikään näppäin jää painetuksi kun kontrollit pysäytetään.
        for k, _ in pairs( isPressed ) do
            isPressed[k] = false
        end

		playerRef = nil
        callbackMovement = nil
    end
end


return controls
