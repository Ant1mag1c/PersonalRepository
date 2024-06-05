display.setStatusBar( display.HiddenStatusBar )
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )

require( "libs.eventListenerWrapper" )
require( "libs.utils" )
require( "scripts.screen" )

------------------------------------------------------------------------------

-- Aseta cleanLaunch = true, niin peli poistaa käynnistyessään kaikki tallennetut tiedostot.
local cleanLaunch = true

if cleanLaunch then
	system.cleanupFolder( "", system.DocumentsDirectory )
end

------------------------------------------------------------------------------

local lfs = require( "lfs" )
local folder = system.pathForFile( "", system.DocumentsDirectory )

-- Tarkistetaan löytyykö "saves" kansio documents kansiosta, jos ei niin luodaan se:
local savesFolder = lfs.chdir( folder .. "/saves" ) -- chdir = change directory

if not savesFolder then
	-- Siirrytään documents kansioon ja luodaan sen sisään "saves" kansio.
	lfs.chdir( folder )
    lfs.mkdir( "saves" ) -- mkdir = make directory
end

------------------------------------------------------------------------------

-- Ladataan userdata tiedosto, jossa on käyttäjän asetukset:
local loadsave = require( "scripts.loadsave" )
loadsave.debugMode( false )
loadsave.protectData( false )

local _save = loadsave.save
function loadsave.save( data, filename )
	return _save( data, filename, "Fruilo & Berri" )
end

local _load = loadsave.load
function loadsave.load( filename )
	return _load( filename, "Fruilo & Berri" )
end

------------------------------------------------------------------------------

local userdata = loadsave.load( "userdata.json" )
local characterData = require("data.characterData")

-- Jos userdataa ei löydy, niin luodaan se:
if not userdata then
	userdata = require( "data.defaultSettings" )
    loadsave.save( userdata, "userdata.json" )
end

-- Kun userdata on ladattu tiedostosta tai luotu, niin tallennetaan se loadsave moduulin
-- sisäiseen userdata taulukkoon, jolloin se kulkee aina helposti mukana kaikkialla:
loadsave.userdata = table.copy( userdata )

-- Luodaan aina default gamedata taulukko, jotta peli toimii vaikka pelaaja hyppäisi
-- suoraan joihin sceneihin debuggaamaan. gamedata päivitetään tai haetaan uudelleen
-- jos pelaaja menee newGame scenen kautta tai lataa savefilen.
loadsave.gamedata = table.copy( loadsave.userdata.newGame )
loadsave.gamedata.character = table.copy( characterData["mustikka"].stats )
-- Luodaan tyhjä "gear" taulukko, jossa on pelaajan varusteista saamat bonus/miinus statsit.
loadsave.gamedata.character.gear = {}
for k, _ in pairs( loadsave.gamedata.character ) do
	loadsave.gamedata.character.gear[k] = 0
end
-- Muut statsit, jotka tarvitaan, mutta joihin ei tarvitse tehdä vielä muita muutoksia.
loadsave.gamedata.character.name = "mustikka"
loadsave.gamedata.character.healthCurrent = loadsave.gamedata.character.health

------------------------------------------------------------------------------
-- DEBUG: Täytetään kaikki vimpaimet pelaajan inventoryyn.
------------------------------------------------------------------------------
do
	local vimpainData = require( "data.vimpainData" )
	loadsave.gamedata.inventory = {}

	local inventoryCap = 16
	for k, _ in pairs( vimpainData ) do
		loadsave.gamedata.inventory[#loadsave.gamedata.inventory+1] = k
		if #loadsave.gamedata.inventory == inventoryCap then
			break
		end
	end
	-- table.print( loadsave.gamedata )
end
------------------------------------------------------------------------------


-- Kutsutaan updateAudio moduulia, joka päivittää äänet ja musiikit:
local sfx = require( "scripts.updateAudio" )
sfx.update()

-- Katsotaan save datasta, onko fullscreen päällä vai ei ja laitetaan peli vastaavasti:
if loadsave.userdata["fullscreen"] then
	native.setProperty( "windowMode", "fullscreen" )
else
	native.setProperty( "windowMode", "normal" )
end


------------------------------------------------------------------------------

local composer = require( "composer" )
composer.recycleOnSceneChange = true

-- composer.gotoScene( "scenes.mainMenu", { effect = "fade", time = 500 } )
-- composer.gotoScene( "scenes.game", { effect = "fade", time = 100 } )
-- composer.gotoScene( "scenes.loadGame", { effect = "fade", time = 100 } )

-- TODO: viholliset alkavat liikkumaan vasta kun ne ovat nähneet pelaajan.

------------------------------------------------------------------------------
-- Devaajille: poista alapuolen komento kommenteista ja määritä mihin sceneen
-- haluat pelin hyppäävän ja mitä sceneParams:eja siirtymässä tulee olla, niin
-- pystyt testaamaan koodiasi/mekaniikoitasi/kenttiäsi nopeasti.
------------------------------------------------------------------------------

composer.gotoScene( "scenes.game", {
	params = {
		map = "m1_F_test",
		spawn = "1_forest",
		-- invulnerability = true, -- Jos "true", niin viholliset eivät osu pelaajaan.
		-- physicsDrawMode = "hybrid", -- sallitut arvot: "hybrid" tai "normal".
		debugArena = true, -- Jos "true", niin oikeaa kenttää ei ladata, vaan pelaaja viedään tyhjään "debug areenan".
		fullInventory = true, -- debug asetus: laittaa pelaajan inventoryyn kaikki pelin vimpaimet
	},
} )

------------------------------------------------------------------------------