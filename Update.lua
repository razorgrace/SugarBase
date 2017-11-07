local addonName, addonNamespace = ...

addonNamespace.Update = function (Spell)
    return {
        Update = function (current)
            local find = function (records, property, value)
                for i, record in ipairs(records) do
                    if record[property] == value then
                        return record
                    end
                end
            end
        
            local races = {
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
        
            local roles = {
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
        
            local classes = (function ()
                local result = {}
        
                for i = 1, GetNumClasses() do
                    local name, tag, id = GetClassInfo(i)
                    result[id] = {
                        id = id,
                        tag = tag,
                        name = name,
                    }
                end
        
                return result
            end)()
        
            local primaryStats = {
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
        
            local specializations = (function ()
                local result = {}
        
                for i = 1, GetNumClasses() do
                    local _, _, classId = GetClassInfo(i)
        
                    for specializationIndex = 1, GetNumSpecializationsForClassID(classId) do
                        local id, name, _, iconId, roleTag, _, _ = GetSpecializationInfoForClassID(classId, specializationIndex)
                        result[id] = {
                            id = id,
                            index = specializationIndex,
                            classId = classId,
                            roleId = find(roles, 'tag', roleTag).id,
                            name = name,
                            icon = iconId,
                        }
                    end        
                end
        
                return result
            end)()
        
            local talents = (function (current)
                local _, classTag, classId = UnitClass('player')
        
                for specializationIndex = 1, GetNumSpecializationsForClassID(classId) do
                    local specializationId, _, _, _, _, _ = GetSpecializationInfoForClassID(classId, specializationIndex)
                    for tier, level in ipairs(CLASS_TALENT_LEVELS[classTag] or CLASS_TALENT_LEVELS.DEFAULT) do
                        for column = 1, 3 do
                            local id, name, texture, _, _, spellId, _, _, _, _, _ = GetTalentInfoBySpecialization(specializationIndex, tier, column)
                            print('GetTalentInfoBySpecialization', specializationIndex, tier, column, GetTalentInfoBySpecialization(specializationIndex, tier, column))
                            current[id] = {
                                id = id,
                                specializationId = specializationId,
                                name = name,
                                texture = texture,
                                level = level,
                                tier = tier,
                                column = column,
                                spellId = spellId,
                            }
                        end
                    end
                end
                            
                return current
            end)(current.talents or {})

            Spell.UpdateData(current)
        
            current.races = races
            current.roles = roles
            current.primaryStats = primaryStats
            current.classes = classes
            current.specializations = specializations
            current.talents = talents
            current.spells = spells
        
            return current
        end,
    }
end