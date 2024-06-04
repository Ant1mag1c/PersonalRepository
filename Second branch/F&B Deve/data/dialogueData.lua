
-- Kaikki pelin cutscenet.

-- Jokaisella cutscenellä on oma id, jonka alta löytyy lista kuvia ja/tai tekstejä.
-- Jokaisessa cutscenessä on oltava jokin kuva, mutta teksti on vapaaehtoinen.
-- Jokaisen "id":n viimeisessä cutscene-taulukossa voi olla "event", jolla voidaan käynnistää koodissa jokin toiminto.

return {

	-- scene1 on cutscene-taulukon id. Tässä cutscenessä on 4 erillistä tapahtumaa, eli pelaajan
	-- tulee painaa jotain näppäintä 4 kertaa, että tämä käy kaikki cutscene kuvat läpi.
	scene1 = {
		{
			image = "Scene1_1.png",
			text = "Come [player]. Time to wake up!",
		},
		{
			image = "Scene1_2.png",
			text = "It’s been over a week since we sent our brave and noble [Apple Knight] ventured beyond the bramble wall. As his squire it is now your task to follow him and bring him home. However….",
		},
		{
			image = "Scene1_3.png",
			text = "The encroaching brambles have completely blocked our path to [Small Village]. Lucky you I guess, you get to stay in the village and do whatever it is that you do all day.",
		},
		{
			image = "Scene1_4.png",
			text = "Elder! We found a clearing in the brambles in the east!",
		},
		{
			image = "Scene1_5.png",
			text = "Perfect timing. [Player] go forth, find our champion and help him figure out what is going on with this encroaching wall of doom.",
			event = "startGame", -- erillinen käsky, joka pitää myöhemmin koodata peliin.
		},
--		{
--			image = "jokinKuva2.png",
--			-- Kuvan mukana ei ole mitään tekstiä.
--		},
--		{
--			image = "jokinKuva3.png",
--			text = "Let's do this!",
--			event = "startGame", -- erillinen käsky, joka pitää myöhemmin koodata peliin. 
--		},
	},

	scene2 = {
		{
			image = "Scene2_1.png",
		},
		{
			image = "Scene2_2.png",
			text = "Ow ow ow."
		},
		{
			image = "Scene2_3.png",
			text = "Thank you stranger."
		},
		{
			image = "Scene2_3.png",
			text = "You'r not like the others."
		},
		{
			image = "Scene2_3.png",
			text = "[peruna] has taken control over the regoin and is using his cultists to spread his corruption."
		},
		{
			image = "Scene2_4.png",
			text = "Pleace stop him."
			event = "bossFight_1",
		},

		

	},

	scene3 = {
		{
			image = "Scene3_1.png",
		},
		{
			image = "Scene3_2.png",
			text = "No, no, NO! NO! NO!",
		},
		{
			image = "Scene3_3.png",
		},
		{
			image = "Scene3_4.png",
			event = "m2_enchantedForest",
		},

		

	},

	scene4 = {
		{
			image = "Scene4_1.png",
			text = "No, no, NO! NO! NO!",
		},
		{
			image = "Scene4_2.png",
		},
		{
			image = "Scene4_3.png",
			text = "I Will not be denied my glorious empire!",
		},
		{
			image = "Scene4_4.png",
			text = "Especially by some little berry like you!",
			event = "bossFight_2",
		},


}