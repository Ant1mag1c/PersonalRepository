local controls = {}

-- Julistetaan muuttujat, joita käytetään tässä moduulissa. Nämä muuttujat ovat paikallisia, eli ne eivät ole näkyvissä muissa moduuleissa.
-- Niille annetaan arvot vasta, kun kontrollit startataan. Kun muuttujat ovat tiedoston alussa, niin ne ovat näkyvissä koko tiedostossa.
local callbackMovement = nil
-- local callbackKey = nil

local direction
local hasStarted = false
local isPressed = {}
local target

-- Ladataan userdata tiedosto, jossa on käyttäjän/pelin asetukset esim. käytettävistä/sallituista kontrollinäppäimistä.

local keyActions = {
	s = { action = function() target.vy = 1 end, dir = "down" },
	w = { action = function() target.vy = -1 end, dir = "up" },
	d = { action = function() target.vx = 1 end, dir = "right" },
	a = { action = function() target.vx = -1 end, dir = "left" },

	left = { action = function() target:attackMelee("left") end, dir = "left" },
	right = { action = function() target:attackMelee("right") end, dir = "right" },
	up = { action = function() target:attackMelee("up") end, dir = "up" },
	down = { action = function() target:attackMelee("down") end, dir = "down" },

	space = { action = function() target:block() end, dir = "down" },
}

-- Funktio, joka kutsutaan joka frame. Tässä funktiossa tarkistetaan, ovatko tietyt liikkumisnäppäimet painettuna ja kutsutaan callbackMovement funktiota.
local function monitorControls()
	target.vx, target.vy = 0, 0

	if not target.isAttacking then
		for k,v in pairs( isPressed ) do
			if v.action then
				v.action()
				target.lookingDir = v.dir and v.dir or nil
			end
		end

		-- Looking up or down needs to be forced for nimation to behave properly
		if isPressed["w"] or isPressed["s"] then
			target.lookingDir = isPressed["w"] and "up" or isPressed["s"] and "down"
		end
	end

	-- During attack player can't move
	if not target.isAttacking then
		callbackMovement(target.vx, target.vy)
	else
		target:hold()
	end
end


-- Funktio, joka kutsutaan aina kun mikä tahansa nappi painetaan pohjaan tai se päästetään ylös.
local function onKeyEvent(event)
	local mapped = keyActions[event.keyName]
	-- print(event.keyName, mapped, event.phase)
	if mapped then
		if event.phase == "down" then
			isPressed[event.keyName] = mapped
		elseif event.phase == "up" then
			isPressed[event.keyName] = nil
		end
	end

	return false
end

function controls.start(player, callBack)
	if not hasStarted then
		hasStarted = true
		target = player
		callbackMovement = callBack

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