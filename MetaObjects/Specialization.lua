local addonName, addonNamespace = ...

local find = function (records, property, value)
    for i, record in ipairs(records) do
        if record[property] == value then
            return record
        end
    end
end

local function generateSpecializations(roles)
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
end

addonNamespace.Specialization = function ()
    return {
        Update = function (data)
            data.specializations = generateSpecializations(data.roles)
        end,
    }
end