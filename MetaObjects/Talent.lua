local addonName, addonNamespace = ...

local function generateTalents(current)
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
end

addonNamespace.Talent = function ()
    return {
        Update = function (data)
            data.talents = generateTalents(data.talents or {})
        end,
    }
end