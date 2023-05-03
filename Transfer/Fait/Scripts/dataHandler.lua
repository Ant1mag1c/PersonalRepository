local dataHandler = {}

local cache = {}

-- Lue .tsv-tiedosto ja muuta se pelille käyttäkelpoiseksi lua taulukoksi.
function dataHandler.getData( filename )
	-- Tiedosto on jo kertaalleen luettu, niin sitä ei tarvitse käsitellä uudestaan.
	if cache[filename] then
		return cache[filename]
	end

	-- Lue tiedosto ja kerro jos jokin menee pieleen.
	local path = system.pathForFile( "Data/Sisuvala - " .. filename, system.ResourceDirectory )
	if not path then
		print( "'getData' - path error: \"Data/Sisuvala - " .. filename .. "\" not found." )
	else
		local file, errorString = io.open( path, "r" )

		if not file then
			print( "'getData' - file error: " .. errorString )
		else
			local header = {}
			local data = {}
			local entries = 0
			local n = 0

			for line in file:lines() do
				-- Erotellaan data tab-merkkien perusteella (huom! tsv = tab-separated values).
				local t = string.split( line, "\t" )
				-- Ota ensimmäiseltä riviltä muuttujien nimet.
				if n == 0 then
					for i = 1, #t do
						header[i] = t[i]
						entries = entries+1
					end
				-- Laadi muista riveistä Lua taulukko.
				else
					local row = {}
					-- Jätä muut kolumnit lukematta jos niitä on enemmän kuin muuttujia.
					for i = 1, entries do
						-- Katso onko muuttuja numero, jos on niin muuta se sellaiseksi.
						-- Muussa tapauksessa tallenna se sellaisenaan.
						row[header[i]] = tonumber( t[i] ) or t[i]
					end

					-- Käytä rivin id-elementtiä sen tunnisteena ja lisää
					-- rivi tiedoston yhteiseen suurempaan lua taulukkoon.
					data[row.id] = row
					-- id on jo käytetty, eikä sitä tarvita muuhun, niin
					-- poistetaan se muistista.
					data[row.id].id = nil
				end
				n = n+1
			end

			-- Tiedosto tulee aina sulkea sen jälkeen kun sitä ei enää
			-- tarvitse, jotta se ei jää käyttöjärjestelmällä lukkoon.
			io.close( file )

			-- Varastoi prosessoitu taulukko ensi kertaa varten.
			cache[filename] = data

			return data
		end
	end
end

return dataHandler