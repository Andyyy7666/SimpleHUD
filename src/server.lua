-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Used to retrive the players discord server nickname, discord name and tag, and the roles.
function getUserDiscordInfo(discordUserId)
    local data
    PerformHttpRequest("https://discordapp.com/api/guilds/" .. server_config.guildId .. "/members/" .. discordUserId, function(errorCode, resultData, resultHeaders)
		if errorCode ~= 200 then
            return
        end
        local result = json.decode(resultData)
        local roles = {}
        for _, roleId in pairs(result.roles) do
            roles[roleId] = roleId
        end
        data = {
            nickname = result.nick,
            discordTag = tostring(result.user.username) .. "#" .. tostring(result.user.discriminator),
            roles = roles
        }
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. server_config.discordServerToken})
    while not data do
        Citizen.Wait(0)
    end
    return data
end

-- Get player any identifier, available types: steam, license, xbl, ip, discord, live.
function GetPlayerIdentifierFromType(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

if config.enablePriorityStatus then
    local priority = "~s~Priority: ~g~Available"
    local priorityPlayers = {}
    local isPriorityCooldown = false
    local isPriorityActive = false

    -- concat tables that doesn't work with table.concat().
    function tableConcat(table, concat)
        local string = ""
        local first = true
        for _, v in pairs(table) do
            if first then
                string = tostring(v)
                first = false
            else
                string = string .. concat .. tostring(v)
            end
        end
        return string
    end

    -- count how many values the table has, when #table doesn't work.
    function tableCount(table)
        local count = 0
        for _ in pairs(table) do
            count = count + 1
        end
        return count
    end

    -- Priority cooldown countdown.
    function priorityCooldown(time)
        isPriorityActive = false
        isPriorityCooldown = true
        for cooldown = time, 1, -1 do
            if cooldown > 1 then
                priority = "~s~Priority Cooldown: ~c~" .. cooldown .. " minutes"
            else
                priority = "~s~Priority Cooldown: ~c~" .. cooldown .. " minute"
            end
            TriggerClientEvent("AndyHUD:returnPriority", -1, priority)
            Citizen.Wait(60000)
        end
        priority = "~s~Priority: ~g~Available"
        TriggerClientEvent("AndyHUD:returnPriority", -1, priority)
        isPriorityCooldown = false
    end

    -- update priority on new client.
    RegisterNetEvent("AndyHUD:getPriority")
    AddEventHandler("AndyHUD:getPriority", function()
        local player = source
        TriggerClientEvent("AndyHUD:returnPriority", player, priority)
    end)

    -- Start a priority.
    RegisterCommand("prio-start", function(source, args, rawCommand)
        local player = source
        if isPriorityCooldown then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "Cannot start priority due to cooldown."}
            })
            return
        end
        if isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "There's already an active priority."}
            })
            return
        end
        isPriorityActive = true
        priorityPlayers[player] = GetPlayerName(player) .. " #" .. player
        priority = "~s~Priority: ~r~Active ~c~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        TriggerClientEvent("AndyHUD:returnPriority", -1, priority)
    end, false)

    -- stop the priority.
    RegisterCommand("prio-stop", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "There's no active priority to stop."}
            })
            return
        end
        priorityPlayers = {}
        priorityCooldown(config.cooldownAfterPriorityStops)
    end, false)

    -- priority cooldown.
    RegisterCommand("prio-cd", function(source, args, rawCommand)
        local player = source

        if #server_config.discordServerToken > 1 and #server_config.guildId > 1 then
            local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
            local roles = getUserDiscordInfo(discordUserId).roles
            local hasPerms = false
        
            for _, roleId in pairs(config.cooldownAccess) do
                if roles[roleId] or roleId == "0" or roleId == 0 then
                    hasPerms = true
                    break
                end
            end

            if not hasPerms then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Error", "You don't have permission to use this command."}
                })
                return
            end
        end

        print("test")

        local time = tonumber(args[1])
        if time and time > 0 then
            priorityCooldown(time)
        end
    end, false)

    -- joining priorities.
    RegisterCommand("prio-join", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "There's no active priority to join."}
            })
            return
        end
        if priorityPlayers[player] then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "You're already in this priority."}
            })
            return
        end
        priorityPlayers[player] = GetPlayerName(player) .. " #" .. player
        priority = "~s~Priority: ~r~Active ~c~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        TriggerClientEvent("AndyHUD:returnPriority", -1, priority)
    end, false)


    -- leaving priorities.
    RegisterCommand("prio-leave", function(source, args, rawCommand)
        local player = source
        if not isPriorityActive then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "There's no active priority to leave."}
            })
            return
        end
        if tableCount(priorityPlayers) == 1 and priorityPlayers[player] == (GetPlayerName(player) .. " #" .. player) then
            priorityPlayers = {}
            priority = "~s~Priority: ~g~Available"
            isPriorityActive = false
        else
            priorityPlayers[player] = nil
            priority = "~s~Priority: ~r~Active ~c~(" .. tableConcat(priorityPlayers, ", ") .. ")"
        end
        TriggerClientEvent("AndyHUD:returnPriority", -1, priority)
    end, false)
end

-- update and set aop.
if config.enableAopStatus then
    local aop = config.defaultAopStatus
    RegisterCommand("aop", function(source, args, rawCommand)
        local player = source

        if #server_config.discordServerToken > 1 and #server_config.guildId > 1 then
            local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
            local roles = getUserDiscordInfo(discordUserId).roles
            local hasPerms = false
        
            for _, roleId in pairs(config.changeAopAccess) do
                if roles[roleId] or roleId == "0" or roleId == 0 then
                    hasPerms = true
                    break
                end
            end

            if not hasPerms then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {"Error", "You don't have permission to use this command."}
                })
                return
            end
        end

        aop = table.concat(args, " ")
        TriggerClientEvent("AndyHUD:ChangeAOP", -1, aop)
        TriggerClientEvent("chat:addMessage", -1, {
            color = {0, 130, 255},
            multiline = true,
            args = {"AOP", "New Area of Player: ^*" .. aop .. "."}
        })
    end, false)
    
    RegisterNetEvent("AndyHUD:getAop")
    AddEventHandler("AndyHUD:getAop", function()
        local player = source
        TriggerClientEvent("AndyHUD:ChangeAOP", player, aop)
    end)
end

local postals = {}
CreateThread(function()
    postals = json.decode(LoadResourceFile(GetCurrentResourceName(), "postals.json"))
    for i = 1, #postals do
        local postal = postals[i]
        postals[i] = {
            coords = vec(postal.x, postal.y),
            code = postal.code
        }
    end
end)

function getPostal(source)
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)
    local coords = vec(pedCoords.x, pedCoords.y)
    local nearestPostal = nil
    local nearestDist = nil
    local nearestIndex = nil

    for i = 1, #postals do
        local dist = #(coords - postals[i].coords)
        if not nearestDist or dist < nearestDist then
            nearestIndex = i
            nearestDist = dist
        end
    end
    nearestPostal = postals[nearestIndex]

    return nearestPostal.code, nearestPostal
end