local addonName, addonNamespace = ...

_G[addonName] = addonNamespace

addonNamespace.toCamelCase = function (str)
    return str:gsub('[^%w%s]', ''):gsub('(%w)(%w*)', function (a, b) return a:upper() .. b end):gsub('%s+', '')
end

local function EntryPoint()
	LoadAddOn('LibStub')
	
	if not LibStub then
		error('"LibStub" not found')
		return
	end
	
	local lib = LibStub:NewLibrary(addonName .. '-' .. GetAddOnMetadata(addonName, 'Version'), 1)
	
	if not lib then
		return
	end

	local Data = addonNamespace.Data()
	local Spell = addonNamespace.Spell()
	local Player = addonNamespace.Player()
	
	local savedVariable = GetAddOnMetadata(addonName, 'X-SavedVariable')

	lib.UpdateData = function () _G[savedVariable] = updateDatabase(_G[savedVariable] or Data) end
	lib.GetData = function () return Data end
	lib.GetSpellMetaObject = function () return Spell.CreateMetaObject(Data) end
	lib.GetPlayerMetaObject = function () return Player.CreateMetaObject(Data) end
	
	lib.GetMountMetaObject = (function ()
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
	
		return function ()
			return setmetatable({}, { __index = function (self, index)
				local cachedRecord = findMount(function (record)
					return addonNamespace.toCamelCase(record.creatureName) == index
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
	end)()
end

local frame = CreateFrame('FRAME', nil, UIParent)

frame:RegisterEvent('ADDON_LOADED')

frame:SetScript('OnEvent', function (self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == addonName then
		EntryPoint()
		frame:SetScript('OnEvent', nil)
    end
end)

local function updateDatabase(current)
	local find = function (records, property, value)
		for i, record in ipairs(records) do
			if record[property] == value then
				return record
			end
		end
	end

	local races = {
		{
			tag = 'Dwarf',
			name = 'Dwarf',
		},
		{
			tag = 'Draenei',
			name = 'Draenei',
		},
		{
			tag = 'Gnome',
			name = 'Gnome',
		},
		{
			tag = 'Human',
			name = 'Human',
		},
		{
			tag = 'NightElf',
			name = 'Night Elf',
		},
		{
			tag = 'Worgen',
			name = 'Worgen',
		},
		{
			tag = 'BloodElf',
			name = 'Blood Elf',
		},
		{
			tag = 'Goblin',
			name = 'Goblin',
		},
		{
			tag = 'Orc',
			name = 'Orc',
		},
		{
			tag = 'Tauren',
			name = 'Tauren',
		},
		{
			tag = 'Troll',
			name = 'Troll',
		},
		{
			tag = 'Scourge',
			name = 'Scourge',
		},
		{
			tag = 'Pandaren',
			name = 'Pandaren',
		},
	}

	local roles = {
		[1] = {
			id = 1,
			tag = "DAMAGER",
			name = "Damager",
		},
		[2] = {
			id = 2,
			tag = "TANK",
			name = "Tank",
		},
		[3] = {
			id = 3,
			tag = "HEALER",
			name = "Healer",
		},
	}

	local classes = (function ()
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
	end)()

	local primaryStats = {
		LE_UNIT_STAT_STRENGTH = {
			id = LE_UNIT_STAT_STRENGTH,
			name = 'Strength',
		},
		LE_UNIT_STAT_AGILITY = {
			id = LE_UNIT_STAT_AGILITY,
			name = 'Agility',
		},
		LE_UNIT_STAT_STAMINA = {
			id = LE_UNIT_STAT_STAMINA,
			name = 'Stamina',
		},
		LE_UNIT_STAT_INTELLECT = {
			id = LE_UNIT_STAT_INTELLECT,
			name = 'Intellect',
		},
	}

	local specializations = (function ()
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
	end)()

	local talents, spells = (function (current, spells)
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
					
		return current, spells
	end)(current.talents or {}, current.spells or {})

	spells = (function (current)
		local _, _, classId = UnitClass('player')
		
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

		forEachSpellBookItem(function (spellId, name, icon, skillType, classId)
			current[spellId] = {
				id = spellId,
				classId = classId,
				name = name,
				icon = icon,
				classId = classId,
			}
		end)
		
		-- local seen = {}
		-- local _, _, classId = UnitClass('player')
		
		-- for specializationIndex = 1, GetNumSpecializationsForClassID(classId) do
		-- 	local specializationId, _, _, _, _, _ = GetSpecializationInfo(specializationIndex)
		-- 	local spellIdsAndLevels = { GetSpecializationSpells(specializationIndex) }

		-- 	for i = 1, #spellIdsAndLevels, 2 do
		-- 		if spellIdsAndLevels[i] == 2006 then
		-- 			print(spellIdsAndLevels[i])
		-- 		end
		-- 		local level = spellIdsAndLevels[i + 1]
		-- 		local name, _, icon, _, _, _, spellId = GetSpellInfo(spellIdsAndLevels[i])

		-- 		if name:find('Resu') then
		-- 			-- print(name, icon, spellId)
		-- 		end
				
		-- 		-- some spells (e.g. Exhilaration) have several IDs; going to use one that is resolved by game via name
		-- 		local altName, _, altIcon, _, _, _, altSpellId = GetSpellInfo(name)

		-- 		if altSpellId then
		-- 			name = altName
		-- 			icon = altIcon
		-- 			spellId = altSpellId
		-- 		end
				
		-- 		if not seen[spellId] then
		-- 			seen[spellId] = true

		-- 			current[spellId] = {
		-- 				id = spellId,
		-- 				classId = classId,
		-- 				name = name,
		-- 				icon = icon,
		-- 				specializations = {},
		-- 			}
		-- 		end

		-- 		current[spellId].specializations[specializationId] = {
		-- 			id = specializationId,
		-- 			level = level,
		-- 		}
		-- 	end
		-- end

		return current, spells
	end)(spells)

	current.races = races
	current.roles = roles
	current.primaryStats = primaryStats
	current.classes = classes
	current.specializations = specializations
	current.talents = talents
	current.spells = spells

	return current
end