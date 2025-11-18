-- Piilotetaan statusbar simulaattorilla ja muilta alustoilta, joilla se löytyy:
display.setStatusBar( display.HiddenStatusBar )

------------------------------------------------------------
-- Ladataan pelin asetukset ja laitetaan ne päälle.

-- Ladataan userdata tiedosto, jossa on käyttäjän asetukset:
local loadsave = require( "Scripts.loadsave" )
local userdata = loadsave.load( "userdata.json" )

-- Jos userdataa ei löydy, niin luodaan se:
if not userdata then
	userdata = require( "Data.defaultSettings" )
	loadsave.save( userdata, "userdata.json" )
end

-- Kun userdata on ladattu tiedostosta tai luotu, niin tallennetaan se loadsave moduuliin:
loadsave.userdata = {}
for k, v in pairs( userdata ) do
	loadsave.userdata[k] = v
end

-- Kutsutaan updateAudio moduulia, joka päivittää äänet ja musiikit:
local sfx = require( "Scripts.updateAudio" )
sfx.update()

-- Katsotaan save datasta, onko fullscreen päällä vai ei ja laitetaan peli vastaavasti:
if loadsave.userdata["fullscreen"] then
	native.setProperty( "windowMode", "fullscreen" )
else
	native.setProperty( "windowMode", "normal" )
end

------------------------------------------------------------

-- mag ja min tekstuurifilterit viittaavat "magnification" ja "minification" filttereihin, eli miten
-- Solar2D skaalaa tekstuureita suuremmiksi tai pienemmiksi. Jos filtteri on "nearest", niin Solar2D
-- ei skaalaa tekstuureita, vaan näyttää ne sellaisenaan. Tämä on hyödyllistä pikseligrafiikalle.
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "nearest")

------------------------------------------------------------

-- Käytetään composeria siirtymään scenejen välillä:
local composer = require( "composer" )
composer.recycleOnSceneChange = true

-- Siirrytään menu sceneen:
-- composer.gotoScene( "Scenes.menu", { effect = "fade", time = 500 } )

-- composer.gotoScene voi sisältää myös parametreja, jotka välitetään sceneen, esim.
composer.gotoScene( "Scenes.game", { effect = "fade", time = 0, params = {
	level = "First map"
} } )
