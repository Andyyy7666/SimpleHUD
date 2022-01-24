------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING 		  --
--                                                                    --
--               Changes should be made in Config.lua                 --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

function text(text, scale, x, y)
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

function time()
    hour = GetClockHours()
    minute = GetClockMinutes()
    if hour <= 9 then
        hour = "0" .. hour
    end
    if minute <= 9 then
        minute = "0" .. minute
    end
    return hour .. ":" .. minute
end

local zoneName = "San Andreas"
local streetName = "San Andreas"
local crossingRoad = "San Andreas"
local postal = "000"
local compass = "N"

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local zone = GetNameOfZone(coords.x, coords.y, coords.z)
        streetName, crossingRoad = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        streetName = config.streetNames[GetStreetNameFromHashKey(streetName)]
        crossingRoad = GetStreetNameFromHashKey(crossingRoad)
        if crossingRoad ~= "" then
            crossingRoad =  " ~c~/ " .. config.streetNames[crossingRoad]
        end
        zoneName = GetLabelText(zone)
        if config.postalDisplay.enabled then
            postal = exports[config.postalDisplay.resourceName]:getPostal()
        end
        compass = getHeading(GetEntityHeading(ped))
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        text("~c~" .. time() .. " ~s~" .. config.zoneNames[zoneName], config.timeDisplay.scale, config.timeDisplay.x, config.timeDisplay.y)
        text("~c~| ~s~" .. compass .. " ~c~| ~s~" .. streetName .. crossingRoad, config.compassDisplay.scale, config.compassDisplay.x, config.compassDisplay.y)
        if config.postalDisplay.enabled then
            text("~s~Nearby Postal: ~c~" .. postal, config.postalDisplay.scale, config.postalDisplay.x, config.postalDisplay.y)
        end
    end
end)

-- Voice Range
if config.voiceRangeDisplay.enabled then
    local keybindUsed = false
    local isTalking = false
    local CurrentChosenDistance = 2
    local CurrentDistanceValue = config.voiceRangeDisplay.ranges[CurrentChosenDistance].distance
    local CurrentDistanceName = config.voiceRangeDisplay.ranges[CurrentChosenDistance].name

    if config.voiceRangeDisplay.customKeybind then
        RegisterCommand("+voiceDistance", function()
            keybindUsed = true
            keybindUsed = false
        end, false)
        RegisterCommand("-voiceDistance", function()
            keybindUsed = false
        end, false)
        RegisterKeyMapping("+voiceDistance", "Change Voice Proximity", "keyboard", "z")
    end

    -- Check if player is speaking
    if config.voiceRangeDisplay.makeHudSmallerWhileSpeaking then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(50)
                if NetworkIsPlayerTalking(PlayerId()) then
                    isTalking = true
                else
                    isTalking = false
                end
            end
        end)
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            -- change voice
            if IsControlJustPressed(0, config.voiceRangeDisplay.keybind) or keybindUsed then
                if CurrentChosenDistance == #config.voiceRangeDisplay.ranges then
                    CurrentChosenDistance = 1
                else
                    CurrentChosenDistance = CurrentChosenDistance + 1
                end
                CurrentDistanceValue = config.voiceRangeDisplay.ranges[CurrentChosenDistance].distance
                CurrentDistanceName = config.voiceRangeDisplay.ranges[CurrentChosenDistance].name
                if config.voiceRangeDisplay.changeSpeakingDistance then
                    MumbleSetAudioInputDistance(CurrentDistanceValue)
                end
                if config.voiceRangeDisplay.changeHearingDistance then
                    MumbleSetAudioOutputDistance(CurrentDistanceValue)
                end
            end

            -- Blue circle
            if config.voiceRangeDisplay.enableBlueCircle then
                if IsControlPressed(1, config.voiceRangeDisplay.keybind) or keybindUsed then
                    local pedCoords = GetEntityCoords(PlayerPedId())
                    DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, CurrentDistanceValue * 2.0, CurrentDistanceValue * 2.0, 1.0, 40, 140, 255, 150, false, false, 2, false, nil, nil, false)
                end
            end

            -- HUD
            if config.voiceRangeDisplay.makeHudSmallerWhileSpeaking and isTalking then
                text(CurrentDistanceName, config.voiceRangeDisplay.scale / 1.2, config.voiceRangeDisplay.x, config.voiceRangeDisplay.y)
            else
                text(CurrentDistanceName, config.voiceRangeDisplay.scale, config.voiceRangeDisplay.x, config.voiceRangeDisplay.y)
            end
        end
    end)
end
