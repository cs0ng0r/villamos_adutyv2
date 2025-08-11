Bridge = {}
Bridge.Framework = nil
Bridge.PlayerData = {}

if GetResourceState('es_extended') == 'started' then
    Bridge.Framework = 'ESX'
    ESX = exports['es_extended']:getSharedObject()
elseif GetResourceState('qb-core') == 'started' then
    Bridge.Framework = 'QB'
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('^1[villamos_aduty] No supported framework detected! Please ensure ESX or QB-Core is running.^0')
    return
end

print('^2[villamos_aduty] Framework detected: ' .. Bridge.Framework .. '^0')


function Bridge.GetPlayer(source)
    if Bridge.Framework == 'ESX' then
        return ESX.GetPlayerFromId(source)
    elseif Bridge.Framework == 'QB' then
        return QBCore.Functions.GetPlayer(source)
    end
end

function Bridge.GetPlayers()
    if Bridge.Framework == 'ESX' then
        return ESX.GetPlayers()
    elseif Bridge.Framework == 'QB' then
        local players = {}
        for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
            table.insert(players, k)
        end
        return players
    end
end

function Bridge.GetPlayerIdentifier(player)
    if Bridge.Framework == 'ESX' then
        return player.identifier
    elseif Bridge.Framework == 'QB' then
        return player.PlayerData.citizenid
    end
end

function Bridge.GetPlayerGroup(player)
    if Bridge.Framework == 'ESX' then
        return player.getGroup()
    elseif Bridge.Framework == 'QB' then
        if QBCore.Functions.HasPermission(player.PlayerData.source, 'god') then
            return 'god'
        elseif QBCore.Functions.HasPermission(player.PlayerData.source, 'admin') then
            return 'admin'
        elseif QBCore.Functions.HasPermission(player.PlayerData.source, 'mod') then
            return 'mod'
        else
            return 'user'
        end
    end
end

function Bridge.GetPlayerJob(player)
    if Bridge.Framework == 'ESX' then
        return player.getJob()
    elseif Bridge.Framework == 'QB' then
        return {
            name = player.PlayerData.job.name,
            label = player.PlayerData.job.label,
            grade = player.PlayerData.job.grade.level
        }
    end
end

function Bridge.GetPlayerSource(player)
    if Bridge.Framework == 'ESX' then
        return player.source
    elseif Bridge.Framework == 'QB' then
        return player.PlayerData.source
    end
end

if IsDuplicityVersion() then
    function Bridge.RegisterCallback(name, callback)
        if Bridge.Framework == 'ESX' then
            ESX.RegisterServerCallback(name, callback)
        elseif Bridge.Framework == 'QB' then
            QBCore.Functions.CreateCallback(name, callback)
        end
    end

    function Bridge.Notify(source, message)
        if Bridge.Framework == 'ESX' then
            TriggerClientEvent('esx:showNotification', source, message)
        elseif Bridge.Framework == 'QB' then
            TriggerClientEvent('QBCore:Notify', source, message, 'primary', 3000)
        end
    end
else
    function Bridge.TriggerCallback(name, callback, ...)
        if Bridge.Framework == 'ESX' then
            ESX.TriggerServerCallback(name, callback, ...)
        elseif Bridge.Framework == 'QB' then
            QBCore.Functions.TriggerCallback(name, callback, ...)
        end
    end

    function Bridge.GetPlayerData()
        if Bridge.Framework == 'ESX' then
            return ESX.GetPlayerData()
        elseif Bridge.Framework == 'QB' then
            return QBCore.Functions.GetPlayerData()
        end
    end

    function Bridge.Notify(message)
        if Bridge.Framework == 'ESX' then
            TriggerEvent('esx:showNotification', message)
        elseif Bridge.Framework == 'QB' then
            TriggerEvent('QBCore:Notify', message, 'primary', 3000)
        end
    end

    function Bridge.GetPlayerSkin(callback)
        if Bridge.Framework == 'ESX' then
            TriggerEvent('skinchanger:getSkin', callback)
        elseif Bridge.Framework == 'QB' then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.charinfo then
                callback({
                    sex = playerData.charinfo.gender == 1 and 1 or 0
                })
            end
        end
    end

    function Bridge.SetHunger(value)
        if Bridge.Framework == 'ESX' then
            TriggerEvent('esx_status:set', 'hunger', value)
        elseif Bridge.Framework == 'QB' then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'hunger', value)
        end
    end

    function Bridge.SetThirst(value)
        if Bridge.Framework == 'ESX' then
            TriggerEvent('esx_status:set', 'thirst', value)
        elseif Bridge.Framework == 'QB' then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'thirst', value)
        end
    end

    function Bridge.RestoreLoadout()
        if Bridge.Framework == 'ESX' then
            TriggerEvent('esx:restoreLoadout')
        elseif Bridge.Framework == 'QB' then
            TriggerServerEvent('QBCore:Server:RestorePlayerWeapons')
        end
    end
end
