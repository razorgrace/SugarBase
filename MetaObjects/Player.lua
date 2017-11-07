local addonName, addonNamespace = ...

addonNamespace.Player = function ()
    return {
        CreateMetaObject = function (data)
            local result = {}

            local function static(index, records, indexer, predicate)
                local subset = {}

                for _, record in pairs(records) do
                    if indexer(record) == index and predicate(record) then
                        return function () return true end
                    end
                end
            end

            local function dynamic(index, records, indexer, predicate)
                local subset = {}

                for _, record in pairs(records) do
                    if indexer(record) == index then
                        table.insert(subset, record)
                    end
                end

                if next(subset) then
                    return function ()
                        for _, record in pairs(subset) do
                            if predicate(record) then
                                return true
                            end
                        end

                        return false
                    end
                end
            end

            local getters = setmetatable({}, {
                __index = function (self, index)
                    self[index] =
                        static(
                            index,
                            data.races,
                            function (race) return 'is' .. addonNamespace.toCamelCase(race.name) end,
                            function (race) return (select(2, UnitRace('player'))) == race.tag end
                        )
                        or static(
                            index,
                            data.classes,
                            function (class) return 'is' .. addonNamespace.toCamelCase(class.name) end,
                            function (class) return (select(3, UnitClass('player'))) == class.id end
                        )
                        or dynamic(
                            index,
                            data.roles,
                            function (role) return 'is' .. addonNamespace.toCamelCase(role.name) end,
                            function (role) return role.tag == (select(5, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or dynamic(
                            index,
                            data.specializations,
                            function (specialization) return 'is' .. addonNamespace.toCamelCase(specialization.name) end,
                            function (specialization) return specialization.id == (select(1, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or dynamic(
                            index,
                            data.specializations,
                            function (specialization) return 'is' .. addonNamespace.toCamelCase(specialization.name) .. addonNamespace.toCamelCase(data.classes[specialization.classId].name) end,
                            function (specialization) return specialization.id == (select(1, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or dynamic(
                            index,
                            data.talents,
                            function (talent) return 'uses' .. addonNamespace.toCamelCase(talent.name) end,
                            function (talent) return (select(4, GetTalentInfo(talent.tier, talent.column, 1))) end
                        )
                        or dynamic(
                            index,
                            data.talents,
                            function (talent) return 'has' .. addonNamespace.toCamelCase(talent.name) end,
                            function (talent) return (select(5, GetTalentInfo(talent.tier, talent.column, 1))) end
                        )
                        or dynamic(
                            index,
                            data.primaryStats,
                            function (primaryStat) return 'uses' .. addonNamespace.toCamelCase(primaryStat.name) end,
                            function (primaryStat) return (select(6, GetSpecializationInfo(GetSpecialization()))) == primaryStat.id end
                        )
                        or function () return nil end
                    return self[index]
                end
            })

            return setmetatable(result, {        
                __index = function (self, index)
                    return getters[index]()
                end
            })
        end,
    }
end