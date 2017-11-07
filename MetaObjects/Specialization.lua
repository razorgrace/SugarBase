local addonName, addonNamespace = ...

local function generateIdToNameMap()
    local result = {}
    
    for i = 1, GetNumClasses() do
        local _, _, classId = GetClassInfo(i)

        for specializationIndex = 1, GetNumSpecializationsForClassID(classId) do
            local id, name, _, _, _, _, _ = GetSpecializationInfoForClassID(classId, specializationIndex)
            result[id] = name
        end        
    end

    return result
end

local function getAll()
    local result = {}
    
    for classIndex = 1, GetNumClasses() do
        local _, _, classID = GetClassInfo(classIndex)

        for specializationIndex = 1, GetNumSpecializationsForClassID(classID) do
            local specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, specializationIndex)
            table.insert(result, {
                classID = classID,
                specID = specID,
                name = name,
                description = description,
                iconID = iconID,
                role = role,
                isRecommended = isRecommended,
                isAllowed = isAllowed,
            })
        end        
    end

    return result
end

addonNamespace.Specialization = function (Data)
    return {
        Update = function (data)
            data.specializationIdToEnglishName = generateIdToNameMap()
        end,

        GetAll = function ()
            return getAll()
        end,

        GetEnglishNameById = function (id)
            return Data.GetData().specializationIdToEnglishName[id]
        end,
    }
end