local addonName, addonNamespace = ...

local function generateClasses()
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
end

addonNamespace.Class = function ()
    return {
        Update = function (data)
            data.classes = generateClasses()
        end,
    }
end