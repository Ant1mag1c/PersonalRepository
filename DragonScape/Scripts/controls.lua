local controls = {}

-- Julistetaan muuttujat, joita käytetään tässä moduulissa. Nämä muuttujat ovat paikallisia, eli ne eivät ole näkyvissä muissa moduuleissa.
-- Niille annetaan arvot vasta, kun kontrollit startataan. Kun muuttujat ovat tiedoston alussa, niin ne ovat näkyvissä koko tiedostossa.
local callbackMovement = nil
local callbackKey = nil

local hasStarted = false
local isPressed = {}

-- Ladataan userdata tiedosto, jossa on käyttäjän/pelin asetukset esim. käytettävistä/sallituista kontrollinäppäimistä.
local loadsave = require( "Scripts.loadsave" )
local key = {}

-- Luetaan kontrollinäppäimet userdata tiedostosta ja tallennetaan ne key taulukkoon. Kontrollit kuitenkin luetaan ristiin, jolloin
-- esim. "jump" näppäimeksi asetettu näppäin on key taulukossa "up" ja "up" näppäimeksi asetettu näppäin on key taulukossa "jump".
-- Tämän tempun avulla pystymme käyttämään esim. "left", "right", "up", "down" ja "jump" näppäimiä, vaikka näitä vastaavat näppäimet
-- olisivatkin oikeasti WASD ja välilyönti, jne.
for k, v in pairs( loadsave.userdata.controls ) do
	key[v] = k
end

-- Funktio, joka kutsutaan joka frame. Tässä funktiossa tarkistetaan, ovatko tietyt liikkumisnäppäimet painettuna ja kutsutaan callbackMovement funktiota.
local function monitorControls()
	-- x ja y-vektorit, joilla pelaaja liikkuu
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

	-- Annetaan game.lua filen callbackMovement funktiolle x ja y-vektorit, joilla pelaaja liikkuu (tai ei liiku) tämän framen aikana.
	callbackMovement( vx, vy )
end


-- Funktio, joka kutsutaan aina kun mikä tahansa nappi painetaan pohjaan tai se päästetään ylös.
local function onKeyEvent( event )
	-- print( event.phase, event.keyName, key[event.keyName] )

	-- key taulukko sisältää kaikki kontrollit, jotka olemme määrittäneet oletusasetuksissa.
	local keyName = key[event.keyName]

	if keyName then
		isPressed[keyName] = event.phase == "down"

		callbackKey( keyName, event.phase )
	end
end



function controls.start( listenerMovement, listenerKey )
	if not hasStarted then
		hasStarted = true

		-- Asetetaan callbackit, jotka kutsutaan joka frame tai aina kun nappeja painetaan.
		-- Callbackit, tai callback funktiot, ovat funktioita, joita kutsutaan muista sceneistä tai moduuleista.
		callbackMovement = listenerMovement
		callbackKey = listenerKey

		-- Lisätään event listenerit, jotta monitorControls ja onKeyEvent funktioita kutsutaan joka frame tai aina kun nappeja painetaan.
		Runtime:addEventListener( "enterFrame", monitorControls )
		Runtime:addEventListener( "key", onKeyEvent )
	end
end

function controls.stop()
	if hasStarted then
		hasStarted = false

		-- Nollataan isPressed taulukko käymällä kaikki sen sisältämät arvot läpi ja asettamalla ne falseksi.
		-- Tämä varmistaa, että seuraavan kerran kun kontrollit startataan, niin vanhat näppäimet eivät ole "jäänet päälle".
		for k, v in pairs( isPressed ) do
			isPressed[k] = false
		end

		-- Poistetaan event listenerit, niin että monitorControls ja onKeyEvent funktioita ei enää kutsuta.
		Runtime:removeEventListener( "enterFrame", monitorControls )
		Runtime:removeEventListener( "key", onKeyEvent )
	end
end

return controls