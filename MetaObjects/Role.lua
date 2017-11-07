local addonName, addonNamespace = ...

local function generateRoles()
    return {
        [1] = {
            id = 1,
            tag = "DAMAGER",
            name = "Damager",
        },
        [2] = {
            id = 2,
            tag = "TANK",
            name = "Tank",
        },
        [3] = {
            id = 3,
            tag = "HEALER",
            name = "Healer",
        },
    }
end

addonNamespace.Role = function ()
    return {
        Update = function (data)
            data.roles = generateRoles()
        end,
    }
end