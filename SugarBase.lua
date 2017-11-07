local addonName, addonNamespace = ...

_G[addonName] = addonNamespace

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

	local Utils = addonNamespace.Utils()
	local Class = addonNamespace.Class()
	local Data = addonNamespace.Data()
	local Specialization = addonNamespace.Specialization(Data)
	local Spell = addonNamespace.Spell(Utils)
	local Talent = addonNamespace.Talent()
	local Player = addonNamespace.Player(Specialization, Utils)
	local PrimaryStat = addonNamespace.PrimaryStat()
	local Race = addonNamespace.Race()
	local Role = addonNamespace.Role()
	local Mount = addonNamespace.Mount(Utils)
	local Update = addonNamespace.Update(Class, PrimaryStat, Race, Role, Specialization, Spell, Talent)
	
	local savedVariable = GetAddOnMetadata(addonName, 'X-SavedVariable')

	lib.UpdateData = function () _G[savedVariable] = Update.Update(Data.GetData()) end
	lib.GetData = function () return Data.GetData() end
	lib.GetSpellMetaObject = function () return Spell.CreateMetaObject(Data.GetData()) end
	lib.GetPlayerMetaObject = function () return Player.CreateMetaObject(Data.GetData()) end
	lib.GetMountMetaObject = function () return Mount.CreateMetaObject() end

	addonNamespace.Update = function ()
		lib.UpdateData()
	end
end

local frame = CreateFrame('FRAME', nil, UIParent)

frame:RegisterEvent('ADDON_LOADED')

frame:SetScript('OnEvent', function (self, event, arg1)
    if event == 'ADDON_LOADED' and arg1 == addonName then
		EntryPoint()
		frame:SetScript('OnEvent', nil)
    end
end)