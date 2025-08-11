Config = {}

--[[
Locales: hu & en
Decided by `setr ox:locale` in server.cfg
]]

lib.locale()

Config.Commands = true

Config.Icons = {
    "marvel"
}


Config.Perms = {
    "god",
    "admin",
    "mod"
}

Config.Admins = { --a pedet vagy a logót vagy a ruhát ha nem szeretnéd használni állítsd falsera
    ["god"] = { tag = "[GOD]", logo = "marvel", color = { r = 162, g = 0, b = 0 } },
    ["admin"] = { tag = "[ADMIN]", logo = "marvel", color = { r = 162, g = 0, b = 0 } },
    ["mod"] = { tag = "[MOD]", logo = "marvel", color = { r = 162, g = 0, b = 0 } },
}

Config.Notify = function(msg)
    if IsDuplicityVersion() then
        lib.notify(target, {
            title = 'Villamos Aduty',
            description = msg,
            type = 'info'
        })
    else
        lib.notify({
            title = 'Villamos Aduty',
            description = msg,
            type = 'info'
        })
    end
end

