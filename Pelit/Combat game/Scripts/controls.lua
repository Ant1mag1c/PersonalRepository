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
local key = {
    a = "left",
    d = "right",
    w = "up",
    s = "down",
	left = "attleft",
	right = "attright",
	up = "attup",
	down = "attdown",
}


-- Funktio, joka kutsutaan joka frame. Tässä funktiossa tarkistetaan, ovatko tietyt liikkumisnäppäimet painettuna ja kutsutaan callbackMovement funktiota.
local function monitorControls()
	if target.isAttacking then
		-- print(target.isAttacking)
		return false
	end

	local vx, vy = 0, 0


	if not target.isAttacking then
		if isPressed["attleft"] then target:attackMelee("left") end
		if isPressed["attright"] then target:attackMelee("right") end
		if isPressed["attup"] then target:attackMelee("up") end
		if isPressed["attdown"] then target:attackMelee("down") end

		if isPressed["left"] then vx = vx - 1; target.lookingDir = "left" end
		if isPressed["right"] then vx = vx + 1; target.lookingDir = "right" end
		if isPressed["up"] then vy = vy - 1; target.lookingDir = "up" end
		if isPressed["down"] then vy = vy + 1; target.lookingDir = "down" end
	end

	-- During attack player can't move
	if not target.isAttacking then
		callbackMovement(vx, vy)
	else
		target:hold()
	end
end


-- Funktio, joka kutsutaan aina kun mikä tahansa nappi painetaan pohjaan tai se päästetään ylös.
local function onKeyEvent(event)
	local mapped = key[event.keyName]
	-- print(event.keyName, mapped, event.phase)

	if mapped then
		if event.phase == "down" then
			isPressed[mapped] = true

		elseif event.phase == "up" then
			isPressed[mapped] = false
		end
	end

	return false  -- allow event to propagate
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