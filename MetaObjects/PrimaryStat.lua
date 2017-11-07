local addonName, addonNamespace = ...

local function generatePrimaryStats()
    return {
        LE_UNIT_STAT_STRENGTH = {
            id = LE_UNIT_STAT_STRENGTH,
            name = 'Strength',
        },
        LE_UNIT_STAT_AGILITY = {
            id = LE_UNIT_STAT_AGILITY,
            name = 'Agility',
        },
        LE_UNIT_STAT_STAMINA = {
            id = LE_UNIT_STAT_STAMINA,
            name = 'Stamina',
        },
        LE_UNIT_STAT_INTELLECT = {
            id = LE_UNIT_STAT_INTELLECT,
            name = 'Intellect',
        },
    }
end

addonNamespace.PrimaryStat = function ()
    return {
        Update = function (data)
            data.primaryStats = generatePrimaryStats()
        end,
    }
end