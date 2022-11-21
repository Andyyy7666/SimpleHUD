-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local priorityText = ""
local aopText = ""
local zoneName = ""
local streetName = ""
local crossingRoad = ""
local nearestPostal = {}
local compass = ""
local time = ""
local hidden = false
local cash = ""
local bank = ""
local postals = {}

function getAOP()
    return aopText
end

function text(text, x, y, scale, font)
    SetTextFont(font)
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
    else
        return " "
    end
end

function getTime()
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


if config.enableMoneyHud then
    NDCore = exports["ND_Core"]:GetCoreObject()

    AddEventHandler("playerSpawned", function()
        local selectedCharacter = NDCore.Functions.GetSelectedCharacter()
        if not selectedCharacter then return end
        cash = selectedCharacter.cash
        bank = selectedCharacter.bank
    end)

    AddEventHandler("onResourceStart", function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then
        return
        end
        Wait(3000)
        local selectedCharacter = NDCore.Functions.GetSelectedCharacter()
        if not selectedCharacter then return end
        cash = selectedCharacter.cash
        bank = selectedCharacter.bank
    end)

    RegisterNetEvent("ND:setCharacter")
    AddEventHandler("ND:setCharacter", function(character)
        local selectedCharacter = character
        if not selectedCharacter then return end
        cash = selectedCharacter.cash
        bank = selectedCharacter.bank
    end)
    
    RegisterNetEvent("ND:updateCharacter")
    AddEventHandler("ND:updateCharacter", function(character)
        local selectedCharacter = character
        if not selectedCharacter then return end
        cash = selectedCharacter.cash
        bank = selectedCharacter.bank
    end)

    RegisterNetEvent("ND:updateMoney")
    AddEventHandler("ND:updateMoney", function(updatedCash, updatedBank)
        cash = updatedCash
        bank = updatedBank
    end)
end

if config.enableAopStatus then
    RegisterNetEvent("AndyHUD:ChangeAOP")
    AddEventHandler("AndyHUD:ChangeAOP", function(aop)
        aopText = aop
    end)
    TriggerEvent("chat:addSuggestion", "/aop", "Change the current area of play?", {{name="Area", help=""}})
end

if config.enablePriorityStatus then
    TriggerEvent("chat:addSuggestion", "/prio-start", "Start a priority.")
    TriggerEvent("chat:addSuggestion", "/prio-stop", "Stop an active priority.")
    TriggerEvent("chat:addSuggestion", "/prio-cd", "Start a cooldown on priorities.", {
        {name="Time", help="Time in minutes to start a cooldown"}
    })
    TriggerEvent("chat:addSuggestion", "/prio-join", "Join the current priority.")
    TriggerEvent("chat:addSuggestion", "/prio-leave", "Leave the current priority.")

    RegisterNetEvent("AndyHUD:returnPriority")
    AddEventHandler("AndyHUD:returnPriority", function(priority)
        priorityText = priority
    end)
end

AddEventHandler("playerSpawned", function()
    if config.enableAopStatus then
        TriggerServerEvent("AndyHUD:getAop")
    end
    if config.enablePriorityStatus then
        TriggerServerEvent("AndyHUD:getPriority")
    end
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Wait(3000)
    if config.enableAopStatus then
        TriggerServerEvent("AndyHUD:getAop")
    end
    if config.enablePriorityStatus then
        TriggerServerEvent("AndyHUD:getPriority")
    end
end)

function markPostal(code)
    for i = 1, #postals do
        local postal = postals[i]
        if postal.code == code then
            SetNewWaypoint(postal.coords.x, postal.coords.y)
            return
        end
    end
end

RegisterCommand("postal", function(source, args, rawCommand)
    if not args[1] then return end
    markPostal(args[1])
end, false)

RegisterCommand("p", function(source, args, rawCommand)
    if not args[1] then return end
    markPostal(args[1])
end, false)

TriggerEvent("chat:addSuggestion", "/postal", "Mark a postal on the map", {{name="postal", help="The postal code"}})
TriggerEvent("chat:addSuggestion", "/p", "Mark a postal on the map", {{name="postal", help="The postal code"}})


CreateThread(function()
    postals = json.decode(LoadResourceFile(GetCurrentResourceName(), "postals.json"))
    
    for i = 1, #postals do
        local postal = postals[i]
        postals[i] = {
            coords = vec(postal.x, postal.y),
            code = postal.code
        }
    end

    if config.enableSpeedometerMetric then
        speedCalc = 3.6
        speedText = "kmh"
    else
        speedCalc = 2.236936
        speedText = "mph"
    end
    for _, vehicleName in pairs(config.electricVehiles) do
        config.electricVehiles[GetHashKey(vehicleName)] = vehicleName
    end

    nearestPostal = postals[1]
    local nearestDist = 50000.0
    while true do
        ped = PlayerPedId()
        pedCoords = GetEntityCoords(ped)
        local coords = vec(pedCoords.x, pedCoords.y)

        for i = 1, #postals do
            local postal = postals[i]
            local dist = #(coords - postal.coords)
            if nearestDist > dist and postal.code ~= nearestPostal.code then
                nearestPostal = postal
            end
        end
        
        nearestDist = #(coords - nearestPostal.coords)

        streetName, crossingRoad = GetStreetNameAtCoord(pedCoords.x, pedCoords.y, pedCoords.z)
        streetName = GetStreetNameFromHashKey(streetName)
        crossingRoad = GetStreetNameFromHashKey(crossingRoad)
        zoneName = GetLabelText(GetNameOfZone(pedCoords.x, pedCoords.y, pedCoords.z))
        if config.streetNames[streetName] then
            streetName = config.streetNames[streetName]
        end
        if config.streetNames[crossingRoad] then
            crossingRoad = config.streetNames[crossingRoad]
        end
        if config.zoneNames[GetLabelText(zoneName)] then
            zoneName = config.zoneNames[GetLabelText(zoneName)]
        end
        if getHeading(GetEntityHeading(ped)) then
            compass = getHeading(GetEntityHeading(ped))
        end
        if crossingRoad ~= "" then
            streetName = streetName .. " ~c~/ " .. crossingRoad
        else
            streetName = streetName
        end
        Wait(1000)
    end
end)

CreateThread(function()
    Wait(500)
    while true do
        Wait(300)
        time = getTime()
        hidden = IsHudHidden()
        vehicle = GetVehiclePedIsIn(ped)
        vehClass = GetVehicleClass(vehicle)
        driver = GetPedInVehicleSeat(vehicle, -1)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if config.enableMoneyHud then
            text("💵", 0.885, 0.028, 0.35, 7)
            text("💳", 0.885, 0.068, 0.35, 7)
            text("~g~$~w~".. cash, 0.91, 0.03, 0.55, 7)
            text("~b~$~w~".. bank, 0.91, 0.07, 0.55, 7)
        end
        if not hidden then
            if config.enableAopStatus then
                text("~s~AOP: ~c~" .. aopText, 0.168, 0.868, 0.40, 4)
            end
            if config.enablePriorityStatus then
                text(priorityText, 0.168, 0.890, 0.40, 4)
            end
            if config.enablePostals and nearestPostal.code then
                text("~s~Nearby Postal: ~c~(" .. nearestPostal.code .. ")", 0.168, 0.912, 0.40, 4)
            end
            text("~c~" .. time .. " ~s~" .. zoneName, 0.168, 0.96, 0.40, 4)
            text("~c~| ~s~" .. compass .. " ~c~| ~s~" .. streetName, 0.168, 0.932, 0.55, 4)
        end
        if vehicle ~= 0 and vehClass ~= 13 and driver then
            DrawRect(0.139, 0.947, 0.035, 0.03, 0, 0, 0, 100)
            text(tostring(math.ceil(GetEntitySpeed(vehicle) * speedCalc)), 0.124, 0.931, 0.5, 4)
            text(speedText, 0.14, 0.94, 0.3, 4)
            if config.enableFuelHUD then
                local fuelLevel = (0.141 * GetVehicleFuelLevel(vehicle)) / 100 -- Fuel Value x Max Bar Width Show The Level Range Within The Bar
                DrawRect(0.0855, 0.8, 0.141, 0.010 + 0.006, 40, 40, 40, 150)  -- Bar Background (Black)
                if config.electricVehiles[GetEntityModel(vehicle)] then
                    DrawRect(0.0855, 0.8, 0.141, 0.010, 20, 140, 255, 100)  -- Bar Background (lighter blue)
                    DrawRect(0.0855 - (0.141 - fuelLevel) / 2, 0.8, fuelLevel, 0.010, 20, 140, 255, 255)  -- Current Fuel (Blue)
                else
                    DrawRect(0.0855, 0.8, 0.141, 0.010, 206, 145, 40, 100)  -- Bar Background (lighter yellow)
                    DrawRect(0.0855 - (0.141 - fuelLevel) / 2, 0.8, fuelLevel, 0.010, 206, 145, 0, 255)  -- Current Fuel (Yellow)
                end
            end
        end
    end
end)
