local addonName, addonNamespace = ...

addonNamespace.Player = function (Specialization, Utils)
    return {
        CreateMetaObject = function (data)
            local result = {}

            local getters = setmetatable({}, {
                __index = function (self, index)
                    self[index] =
                        Utils.static(
                            index,
                            data.races,
                            function (race) return 'is' .. Utils.toCamelCase(race.name) end,
                            function (race) return (select(2, UnitRace('player'))) == race.tag end
                        )
                        or Utils.static(
                            index,
                            data.classes,
                            function (class) return 'is' .. Utils.toCamelCase(class.name) end,
                            function (class) return (select(3, UnitClass('player'))) == class.id end
                        )
                        or Utils.dynamic(
                            index,
                            data.roles,
                            function (role) return 'is' .. Utils.toCamelCase(role.name) end,
                            function (role) return role.tag == (select(5, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or Utils.dynamic(
                            index,
                            Specialization.GetAll(),
                            function (specialization) return 'is' .. Utils.toCamelCase(Specialization.GetEnglishNameById(specialization.specID)) end,
                            function (specialization) return specialization.specID == (select(1, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or Utils.dynamic(
                            index,
                            Specialization.GetAll(),
                            function (specialization) return 'is' .. Utils.toCamelCase(Specialization.GetEnglishNameById(specialization.specID)) .. Utils.toCamelCase(data.classes[specialization.classID].name) end,
                            function (specialization) return specialization.specID == (select(1, GetSpecializationInfo(GetSpecialization()))) end
                        )
                        or Utils.dynamic(
                            index,
                            data.talents,
                            function (talent) return 'uses' .. Utils.toCamelCase(talent.name) end,
                            function (talent) return (select(4, GetTalentInfo(talent.tier, talent.column, 1))) end
                        )
                        or Utils.dynamic(
                            index,
                            data.talents,
                            function (talent) return 'has' .. Utils.toCamelCase(talent.name) end,
                            function (talent) return (select(5, GetTalentInfo(talent.tier, talent.column, 1))) end
                        )
                        or Utils.dynamic(
                            index,
                            data.primaryStats,
                            function (primaryStat) return 'uses' .. Utils.toCamelCase(primaryStat.name) end,
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