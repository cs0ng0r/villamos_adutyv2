local inDuty = {}
local tags = {}
local dutyTimes = json.decode(LoadResourceFile(GetCurrentResourceName(), "data.json")) or {}

Bridge.RegisterCallback("villamos_aduty:openPanel", function(source, cb)
    local xAdmin = Bridge.GetPlayer(source)
    if not IsAdmin(Bridge.GetPlayerGroup(xAdmin)) then return cb(false) end
    local players = {}
    local play = Bridge.GetPlayers()
    for i = 1, #play do
        local xPlayer = Bridge.GetPlayer(play[i])

        if xPlayer then
            players[#players + 1] = {
                id = Bridge.GetPlayerSource(xPlayer),
                name = GetPlayerName(Bridge.GetPlayerSource(xPlayer)),
                group = Bridge.GetPlayerGroup(xPlayer),
                job = Bridge.GetPlayerJob(xPlayer).label
            }
        end
    end

    cb(true, Bridge.GetPlayerGroup(xAdmin), players)
end)

RegisterNetEvent('villamos_aduty:setTag', function(enable)
    local xPlayer = Bridge.GetPlayer(source)
    if not inDuty[Bridge.GetPlayerSource(xPlayer)] then return end

    tags[Bridge.GetPlayerSource(xPlayer)] = enable and inDuty[Bridge.GetPlayerSource(xPlayer)].tag or nil
    TriggerClientEvent("villamos_aduty:sendData", -1, tags)
end)

RegisterNetEvent('villamos_aduty:setDutya', function(enable)
    local xPlayer = Bridge.GetPlayer(source)
    if inDuty[Bridge.GetPlayerSource(xPlayer)] then
        TriggerClientEvent("villamos_aduty:setDuty", Bridge.GetPlayerSource(xPlayer), false,
            inDuty[Bridge.GetPlayerSource(xPlayer)].group)
        if tags[Bridge.GetPlayerSource(xPlayer)] then
            tags[Bridge.GetPlayerSource(xPlayer)] = nil
            TriggerClientEvent("villamos_aduty:sendData", -1, tags)
        end
        local dutyMinutes = math.floor((os.time() - inDuty[Bridge.GetPlayerSource(xPlayer)].start) / 60)
        inDuty[Bridge.GetPlayerSource(xPlayer)] = nil
        Bridge.Notify(-1, locale("went_offduty", GetPlayerName(Bridge.GetPlayerSource(xPlayer))))

        dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] = (dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] or 0) +
            dutyMinutes
        SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
        LogToDiscord(GetPlayerName(Bridge.GetPlayerSource(xPlayer)), false,
            FormatMinutes(dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] or 0), FormatMinutes(dutyMinutes))
    else
        local group = Config.DiscordTags and GetDiscordRole(Bridge.GetPlayerSource(xPlayer)) or
            Bridge.GetPlayerGroup(xPlayer)

        if not group or not Config.Admins[group] then
            return Bridge.Notify(Bridge.GetPlayerSource(xPlayer),
                locale("cant_duty"))
        end

        inDuty[Bridge.GetPlayerSource(xPlayer)] = {
            tag = { label = Config.Admins[group].tag .. " " .. GetPlayerName(Bridge.GetPlayerSource(xPlayer)), color = Config.Admins[group].color, logo = Config.Admins[group].logo },
            group = group,
            start = os.time()
        }
        TriggerClientEvent("villamos_aduty:setDuty", Bridge.GetPlayerSource(xPlayer), true, group)
        Bridge.Notify(-1, locale("went_onduty", GetPlayerName(Bridge.GetPlayerSource(xPlayer))))

        tags[Bridge.GetPlayerSource(xPlayer)] = inDuty[Bridge.GetPlayerSource(xPlayer)].tag
        TriggerClientEvent("villamos_aduty:sendData", -1, tags)

        LogToDiscord(GetPlayerName(Bridge.GetPlayerSource(xPlayer)), true,
            FormatMinutes((dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] or 0)))
    end
end)

AddEventHandler('playerDropped', function(reason)
    local xPlayer = Bridge.GetPlayer(source)
    if not xPlayer or not inDuty[Bridge.GetPlayerSource(xPlayer)] then return end
    if tags[Bridge.GetPlayerSource(xPlayer)] then
        tags[Bridge.GetPlayerSource(xPlayer)] = nil
        TriggerClientEvent("villamos_aduty:sendData", -1, tags)
    end
    local dutyMinutes = math.floor((os.time() - inDuty[Bridge.GetPlayerSource(xPlayer)].start) / 60)
    inDuty[Bridge.GetPlayerSource(xPlayer)] = nil
    Bridge.Notify(-1, locale("went_offduty", GetPlayerName(Bridge.GetPlayerSource(xPlayer))))

    dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] = (dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] or 0) + dutyMinutes
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dutyTimes), -1)
    LogToDiscord(GetPlayerName(Bridge.GetPlayerSource(xPlayer)), false,
        FormatMinutes(dutyTimes[Bridge.GetPlayerIdentifier(xPlayer)] or 0), FormatMinutes(dutyMinutes))
end)

if Bridge.Framework == 'ESX' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(playerData)
        TriggerClientEvent("villamos_aduty:sendData", source, tags)
    end)
elseif Bridge.Framework == 'QB' then
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        TriggerClientEvent("villamos_aduty:sendData", source, tags)
    end)
end

function LogToDiscord(name, duty, alltime, time)
    if not Config.Webhook then return end
    local connect = {
        {
            ["color"] = (duty and 27946 or 10616832),
            ["title"] = "**" .. name .. "**",
            ["description"] = (duty and locale("went_onduty", name) or locale("went_offduty", name)),
            ["fields"] = {
                {
                    ["name"] = locale("alltime"),
                    ["value"] = alltime,
                    ["inline"] = true
                },
                {
                    ["name"] = locale("dutytime"),
                    ["value"] = time or "-",
                    ["inline"] = true
                },
            },
            ["author"] = {
                ["name"] = "Marvel Studios",
                ["url"] = "https://discord.gg/esnawXn5q5",
                ["iconlocalerl"] =
                "https://cdn.discordapp.com/attachments/917181033626087454/954753156821188658/marvel1.png"
            },
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %X") .. " | villamos_aduty :)",
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({ embeds = connect }),
        { ['Content-Type'] = 'application/json' })
end

function FormatMinutes(m)
    local minutes = m % 60
    local hours = math.floor((m - minutes) / 60)
    return hours .. " h " .. minutes .. " m"
end

function IsAdmin(group)
    for i = 1, #Config.Perms do
        if Config.Perms[i] == group then
            return true
        end
    end

    return false
end

function GetPlayerDiscord(src)
    local identifiers = GetPlayerIdentifiers(src)

    for i = 1, #identifiers do
        if string.find(identifiers[i], 'discord:') then
            return string.sub(identifiers[i], 9)
        end
    end

    return nil
end

function GetDiscordRole(src)
    local api = Config.DiscordTimeOut
    local discordId = GetPlayerDiscord(src)
    local info

    if not discordId then return nil end

    PerformHttpRequest("https://discordapp.com/api/guilds/" .. Config.GuildId .. "/members/" .. discordId,
        function(errorCode, resultData, resultHeaders)
            api = 0
            if not resultData then return end
            local roles = json.decode(resultData).roles
            for v = 1, #roles do
                for role, _ in pairs(Config.Admins) do
                    if roles[v] == role then
                        info = role
                        break
                    end
                end
            end
        end, "GET", "", { ["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. Config.BotToken })

    while api > 0 do
        Wait(100)
        api = api - 100
    end

    return info
end

exports('GetDutys', function()
    return inDuty
end)

exports('IsInDuty', function(src)
    return inDuty[src] and true or false
end)
