local addonName, addonNamespace = ...

addonNamespace.Spell = function ()
    return {
        CreateMetaObject = function (data)
            local result = {}
            
            setmetatable(result, {
                __index = function (self, index)
                    -- if spellQuery[index] then
                    --     return spellQuery[index](spellID)
                    -- else
                    --     error('Unknown spell index requested: ' .. tostring(index))
                    -- end
        
                    for _, spell in pairs(data.spells) do
                        if not spell or not spell.name then
                            print('Bad spell in DB: #' .. spell.id)
                        elseif addonNamespace.toCamelCase(spell.name) == index then
                            self[index] = setmetatable(
                                {
                                    id = spell.id,
                                    name = (GetSpellInfo(spell.id)),
                                    icon = spell.icon,
                                },
                                {
                                    __tostring = function (self)
                                        return self.name
                                    end,
                                }
                            )
                            return self[index]
                        end
                    end
                end,
            })
        
            return result
        end
    }
end