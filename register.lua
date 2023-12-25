-- Register functionality by: Ian898 
-- Date: 26/11/2018
-- THANK YOU IAN!

-- "by" modelleicher
-- update: 16.01.2023 sbsh
local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or "unknown"

local function initSpecialization(manager)
    if manager.typeName == "vehicle" then
        g_specializationManager:addSpecialization("realismAddon_rpmAnimSpeeds", "realismAddon_rpmAnimSpeeds", modDirectory .. "realismAddon_rpmAnimSpeeds.lua", nil)

        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
                g_vehicleTypeManager:addSpecialization(typeName, modName .. ".realismAddon_rpmAnimSpeeds")
		end
	end
end


local function init()
    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, initSpecialization)
end

init()



























