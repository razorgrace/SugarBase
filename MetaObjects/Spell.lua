local addonName, addonNamespace = ...

local function updateTalentSpells(spells)
    local _, classTag, classId = UnitClass('player')

    for specializationIndex = 1, GetNumSpecializationsForClassID(classId) do
        local specializationId, _, _, _, _, _ = GetSpecializationInfoForClassID(classId, specializationIndex)
        for tier, level in ipairs(CLASS_TALENT_LEVELS[classTag] or CLASS_TALENT_LEVELS.DEFAULT) do
            for column = 1, 3 do
                local id, name, texture, _, _, spellId, _, _, _, _, _ = GetTalentInfoBySpecialization(specializationIndex, tier, column)

                local spellName, _, spellIcon, _, _, _, _ = GetSpellInfo(spellId)

                spells[spellId] = {
                    id = spellId,
                    classId = classId,
                    name = spellName,
                    icon = spellIcon,
                    classId = classId,
                }		
            end
        end
    end
end

local function forEachSpellBookItem(callback)
    for tabIndex = 1, GetNumSpellTabs() do
        local name, texture, offset, numberOfSpells = GetSpellTabInfo(tabIndex)
        for spellIndex = 1, numberOfSpells do
            if not IsPassiveSpell(spellIndex + offset, BOOKTYPE_SPELL) then
                local itemType, itemId = GetSpellBookItemInfo(spellIndex + offset, BOOKTYPE_SPELL)

                if itemType == 'FLYOUT' then
                    local _, _, numberOfSlots, _ = GetFlyoutInfo(itemId)
                    for slotIndex = 1, numberOfSlots do
                        local spellId, _ = GetFlyoutSlotInfo(itemId, slotIndex)
                        local name, _, icon, _, _, _, _ = GetSpellInfo(spellId)
                        callback(spellId, name, icon, skillType, classId)
                    end
                elseif itemType == 'SPELL' then
                    local name, _, icon, _, _, _, spellId = GetSpellInfo(itemId)
                    callback(spellId, name, icon, skillType, classId)
                end
            end
        end
    end
end

local function updateSpellBookSpells(spells)
    local _, _, classId = UnitClass('player')
    
    forEachSpellBookItem(function (spellId, name, icon, skillType, classId)
        spells[spellId] = {
            id = spellId,
            classId = classId,
            name = name,
            icon = icon,
            classId = classId,
        }
    end)
    
    return spells
end

addonNamespace.Spell = function (Utils)
    return {
        UpdateData = function (data)
            if not data.spells then
                data.spells = {}
            end

            updateTalentSpells(data.spells)
            updateSpellBookSpells(data.spells)
        end,

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
                        elseif Utils.toCamelCase(spell.name) == index then
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