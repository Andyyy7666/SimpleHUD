------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING 		  --
--                                                                    --
--               Changes should be made in Config.lua                 --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

-- voice range script
local InputWhisper = false
local InputNormal = true
local InputShouting = false
local isTalking = false
local CurrentDistance = config.voiceRange.NormalDistance
local ToggleHUD = true

-- Compass function
function getHeading(heading)
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return "N" -- North
    elseif (heading >= 45 and heading < 135) then
        return "W" -- West
    elseif (heading >= 135 and heading < 225) then
        return "S" -- South
    elseif (heading >= 225 and heading < 315) then
        return "E" -- East
    end
end

-- Time function
function time()
    hour = GetClockHours()
    minute = GetClockMinutes()
    if hour <= 9 then
        hour = "0" .. hour
    end
    if minute <= 9 then
        minute = "0" .. minute
    end
    return "~c~" .. hour .. ":" .. minute .. " ~s~"
end

-- Text function
function InputText(text, scale, x, y)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
	SetTextJustification(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- command
RegisterCommand("togglehud", function(source, args, rawCommand)
    if ToggleHUD == true then
        ToggleHUD = false
    else
        ToggleHUD = true
    end
end, false)

-- command help
TriggerEvent('chat:addSuggestion', '/togglehud', 'toggle location hud')

-- Area and time display.
Citizen.CreateThread(function()
    local zones = { ['AIRP'] = "LSIA", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GALLI'] = "Galileo Park", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OBSERV'] = "Galileo Observatory", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }
    while true do
        if ToggleHUD then
            ped = PlayerPedId()
            playerCoords = GetEntityCoords(ped)
            AreaDisplay = zones[GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)]
            streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z))
            compass = getHeading(GetEntityHeading(ped))
            isTalking = NetworkIsPlayerTalking(PlayerId())
            postal = exports.nearest_postal:getPostal()
            
            if AreaDisplay == nil then
                AreaDisplay = "San Andreas"
            end
        end
        Citizen.Wait(800)
    end
end)

-- change voice
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if config.voiceRange.enableVoiceRange and ToggleHUD then
            if IsControlJustPressed(0, config.voiceRange.Keybind) then
                if InputWhisper == true then
                    --MumbleSetAudioInputDistance(config.voiceRange.NormalDistance)
                    CurrentDistance = config.voiceRange.NormalDistance
                    InputWhisper = false
                    InputNormal = true
                    InputShouting = false
                elseif InputNormal == true then
                    --MumbleSetAudioInputDistance(config.voiceRange.ShoutingDistance)
                    CurrentDistance = config.voiceRange.ShoutingDistance
                    InputWhisper = false 
                    InputNormal = false
                    InputShouting = true
                elseif InputShouting == true then
                    --MumbleSetAudioInputDistance(config.voiceRange.WhisperDistance)
                    CurrentDistance = config.voiceRange.WhisperDistance
                    InputWhisper = true
                    InputNormal = false
                    InputShouting = false
                end
            end
        end
    end
end)

-- hud
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if ToggleHUD then
            InputText(time() .. AreaDisplay, config.display.TimeScale, config.display.TimeLocationX, config.display.TimeLocationY)
            InputText("~c~| ~s~" .. compass .. " ~c~| ~s~" .. streetName, config.display.CompassStreetnameScale, config.display.CompassStreetnameLocationX, config.display.CompassStreetnameLocationY)
            InputText('~s~Nearby Postal: ~c~' .. postal, config.display.PostalScale, config.display.PostalLocationX, config.display.PostalLocationY)

            if config.voiceRange.enableVoiceRange then
                if InputWhisper == true and isTalking == false then
                    InputText("🔈", config.voiceRange.scale, config.voiceRange.x, config.voiceRange.y)
                elseif InputNormal == true and isTalking == false then
                    InputText("🔉", config.voiceRange.scale, config.voiceRange.x, config.voiceRange.y)
                elseif InputShouting == true and isTalking == false then
                    InputText("🔊", config.voiceRange.scale, config.voiceRange.x, config.voiceRange.y)
                elseif InputWhisper == true and isTalking == true then
                    InputText("🔈", config.voiceRange.scale / 1.2, config.voiceRange.x, config.voiceRange.y)
                elseif InputNormal == true and isTalking == true then
                    InputText("🔉", config.voiceRange.scale / 1.2, config.voiceRange.x, config.voiceRange.y)
                elseif InputShouting == true and isTalking == true then
                    InputText("🔊", config.voiceRange.scale / 1.2, config.voiceRange.x, config.voiceRange.y)
                end
        
                if config.voiceRange.enableBlueCirlce and IsControlPressed(1, config.voiceRange.Keybind) then
                    local pedCoords = GetEntityCoords(PlayerPedId())
                    DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, CurrentDistance * 2.0, CurrentDistance * 2.0, 1.0, 40, 140, 255, 150, false, false, 2, false, nil, nil, false)
                end
            end
        end
    end
end)