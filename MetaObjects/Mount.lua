local addonName, addonNamespace = ...

addonNamespace.Mount = function (Utils)
    return {
        CreateMetaObject = function ()
            -- LoadAddOn("Blizzard_MountCollection")
			
            local getMountInfoById = function (mountID)
                local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(mountID)
        
                if not creatureName then
                    return nil
                end
        
                return {
                    creatureName = creatureName,
                    spellID = spellID,
                    icon = icon,
                    active = active,
                    isUsable = isUsable,
                    sourceType = sourceType,
                    isFavorite = isFavorite,
                    isFactionSpecific = isFactionSpecific,
                    faction = faction,
                    hideOnChar = hideOnChar,
                    isCollected = isCollected,
                    mountID = mountID,
                }
            end
        
            local mountInfoById = setmetatable({}, { __index = function (self, index)
                local record = getMountInfoById(index)
        
                if not record then
                    return nil
                end
        
                self[index] = record
        
                return record
            end })
        
            local function findMount(predicate)
                local incomplete = nil
        
                for mountID = 1, C_MountJournal.GetNumMounts() do
                    local record = mountInfoById[mountID]
        
                    if not record then
                        incomplete = true
                    elseif predicate(record) then
                        return record, incomplete
                    end
                end
        
                if incomplete == nil then
                    incomplete = false
                end
        
                return nil, incomplete
            end
	
			return setmetatable({}, { __index = function (self, index)
				local cachedRecord = findMount(function (record)
					return Utils.toCamelCase(record.creatureName) == index
				end)
				
				if not cachedRecord then
					return {}
				end
	
				local result = {
					id = cachedRecord.mountID,
					name = cachedRecord.creatureName,
				}
	
				local freshRecord = getMountInfoById(cachedRecord.mountID)
	
				if freshRecord then
					result.isUsable = freshRecord.isUsable
				end
	
				self[index] = setmetatable(result, {
					__tostring = function (self)
						return self.name
					end,
				})
	
				return result
			end } )
        end
    }
end