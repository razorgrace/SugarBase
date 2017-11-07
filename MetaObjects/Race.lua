local addonName, addonNamespace = ...

local function generateRaces()
    return {
        {
            tag = 'Dwarf',
            name = 'Dwarf',
        },
        {
            tag = 'Draenei',
            name = 'Draenei',
        },
        {
            tag = 'Gnome',
            name = 'Gnome',
        },
        {
            tag = 'Human',
            name = 'Human',
        },
        {
            tag = 'NightElf',
            name = 'Night Elf',
        },
        {
            tag = 'Worgen',
            name = 'Worgen',
        },
        {
            tag = 'BloodElf',
            name = 'Blood Elf',
        },
        {
            tag = 'Goblin',
            name = 'Goblin',
        },
        {
            tag = 'Orc',
            name = 'Orc',
        },
        {
            tag = 'Tauren',
            name = 'Tauren',
        },
        {
            tag = 'Troll',
            name = 'Troll',
        },
        {
            tag = 'Scourge',
            name = 'Scourge',
        },
        {
            tag = 'Pandaren',
            name = 'Pandaren',
        },
    }
end

addonNamespace.Race = function ()
    return {
        Update = function (data)
            data.races = generateRaces()
        end,
    }
end