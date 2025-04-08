local shadowText = {}

-- Luodaan teksti, jossa on varjo. Koska tätä funktiota kutsutaan usein, niin se on hyvä idea luoda funktio,
-- jota kutsuu sen sijaan, että kirjoittaisi koodin joka kerta uudestaan.
function shadowText.new( params )

	-- Syötetään parametreina annetut arvot display.newText funktioon ja luodaan kaksi tekstiä, joista toinen on varjo.
	local temp = display.newText({
		parent = params.parent,
		text = params.text,
		x = params.x,
		y = params.y,
		font = params.font,
		fontSize = params.fontSize
	})
	-- Ternary operattori, eli katsotaan annettiinko arvoa anchorX. Jos ei, niin käytetään oletusarvoa 0.5.
	temp.anchorX = params.anchorX or 0.5

	local tempShadow = display.newText({
		parent = params.parent,
		text = params.text,
		x = temp.x + 4,
		y = temp.y + 4,
		font = params.font,
		fontSize = params.fontSize
	})
	tempShadow.anchorX = params.anchorX or 0.5

	-- Värjätään varjo mustaksi ja tuodaan "pääteksti" varjon eteen.
	tempShadow:setFillColor( 0 )
	temp:toFront()

	-- Palautetaan viittaukset molempiin teksteihin, jotta niitä voidaan muokata myöhemmin, jos tarvetta on.
	return temp, tempShadow
end

return shadowText