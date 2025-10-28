local controls = {}

-- Julistetaan muuttujat, joita käytetään tässä moduulissa. Nämä muuttujat ovat paikallisia, eli ne eivät ole näkyvissä muissa moduuleissa.
-- Niille annetaan arvot vasta, kun kontrollit startataan. Kun muuttujat ovat tiedoston alussa, niin ne ovat näkyvissä koko tiedostossa.
-- local callbackMovement = nil
-- local callbackKey = nil

local direction
local hasStarted = false
local isPressed = {}
local target

-- Ladataan userdata tiedosto, jossa on käyttäjän/pelin asetukset esim. käytettävistä/sallituista kontrollinäppäimistä.
local key = {
    a = "left",
    d = "right",
    w = "up",
    s = "down"
}


-- Luetaan kontrollinäppäimet userdata tiedostosta ja tallennetaan ne key taulukkoon. Kontrollit kuitenkin luetaan ristiin, jolloin
-- esim. "jump" näppäimeksi asetettu näppäin on key taulukossa "up" ja "up" näppäimeksi asetettu näppäin on key taulukossa "jump".
-- Tämän tempun avulla pystymme käyttämään esim. "left", "right", "up", "down" ja "jump" näppäimiä, vaikka näitä vastaavat näppäimet
-- olisivatkin oikeasti WASD ja välilyönti, jne.

-- Funktio, joka kutsutaan joka frame. Tässä funktiossa tarkistetaan, ovatko tietyt liikkumisnäppäimet painettuna ja kutsutaan callbackMovement funktiota.
local function monitorControls()
	if not target or not target.setLinearVelocity then
		return
	end

	local vx, vy = 0, 0

	if target.isAttacking then
		return
	end

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

	-- Normalize diagonal movement
	if vx ~= 0 or vy ~= 0 then
		local len = math.sqrt(vx*vx + vy*vy)
		vx, vy = (vx/len)*target.speed, (vy/len)*target.speed
	else
		vx, vy = 0, 0
	end

	target:setLinearVelocity(vx, vy)
end

-- Funktio, joka kutsutaan aina kun mikä tahansa nappi painetaan pohjaan tai se päästetään ylös.
local function onKeyEvent(event)
	local mapped = key[event.keyName]
	-- print(event.keyName, mapped, event.phase)
	if mapped then
		if event.phase == "down" then
			isPressed[mapped] = true
			target:handleAnimation()

		elseif event.phase == "up" then
			isPressed[mapped] = false
		end
	end

	return false  -- allow event to propagate
end

function controls.start(player, checkKeysDown)
	if not hasStarted then
		hasStarted = true
		target = player

		Runtime:addEventListener("enterFrame", monitorControls)
		Runtime:addEventListener("key", onKeyEvent)
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