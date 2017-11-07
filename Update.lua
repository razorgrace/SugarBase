local addonName, addonNamespace = ...

addonNamespace.Update = function (Class, PrimaryStat, Race, Role, Specialization, Spell, Talent)
    return {
        Update = function (current)
            Class.Update(current)
            PrimaryStat.Update(current)
            Race.Update(current)
            Role.Update(current)
            Specialization.Update(current)
            Spell.UpdateData(current)
            Talent.Update(current)

            return current
        end,
    }
end