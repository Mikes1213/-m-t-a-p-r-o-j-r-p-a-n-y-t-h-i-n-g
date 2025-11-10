--[[
    Vehicle Variants Client Script for MTA:SA
    Handles loading custom models (DFF/TXD) on client side
]]

-- Store loaded custom models to avoid reloading
local loadedCustomModels = {}

-- Function to load custom model using EngineFreeModel (client-side only)
function loadCustomModel(customID, dffPath, txdPath)
    -- Check if already loaded
    if loadedCustomModels[customID] then
        return true, "Model już załadowany"
    end
    
    -- Free model ID
    if not engineFreeModel(customID) then
        return false, "Nie udało się zwolnić modelu ID: " .. customID
    end
    
    -- Load TXD file first (if provided)
    if txdPath then
        local txd = engineLoadTXD(txdPath, true)
        if not txd then
            return false, "Nie udało się załadować TXD: " .. txdPath
        end
        if not engineImportTXD(txd, customID) then
            return false, "Nie udało się zaimportować TXD dla modelu: " .. customID
        end
    end
    
    -- Load DFF file
    if dffPath then
        local dff = engineLoadDFF(dffPath, customID)
        if not dff then
            return false, "Nie udało się załadować DFF: " .. dffPath
        end
        if not engineReplaceModel(dff, customID) then
            return false, "Nie udało się zastąpić modelu DFF"
        end
    end
    
    loadedCustomModels[customID] = true
    return true, "Custom model załadowany pomyślnie"
end

-- Receive custom model data from server and load it
addEvent("loadCustomModelVariant", true)
addEventHandler("loadCustomModelVariant", root, function(customID, dffPath, txdPath, vehicle)
    if not customID or not dffPath then
        outputDebugString("[Vehicle Variants Client] Missing customID or dffPath")
        return
    end
    
    -- Ensure paths are relative to resource (add :resourceName if needed)
    local resourceName = getResourceName(getThisResource())
    if not string.find(dffPath, ":") then
        dffPath = ":" .. resourceName .. "/" .. dffPath
    end
    if txdPath and not string.find(txdPath, ":") then
        txdPath = ":" .. resourceName .. "/" .. txdPath
    end
    
    -- Load the custom model
    local success, message = loadCustomModel(customID, dffPath, txdPath)
    
    if success and isElement(vehicle) then
        -- Set vehicle model to custom ID
        setElementModel(vehicle, customID)
        triggerServerEvent("onCustomModelLoaded", resourceRoot, vehicle, customID, true, message)
    else
        outputDebugString("[Vehicle Variants Client] Failed to load model: " .. tostring(message))
        triggerServerEvent("onCustomModelLoaded", resourceRoot, vehicle, customID, false, message)
    end
end)

-- Receive request to restore original model
addEvent("restoreOriginalModelVariant", true)
addEventHandler("restoreOriginalModelVariant", root, function(vehicle, originalModel)
    if isElement(vehicle) and originalModel then
        setElementModel(vehicle, originalModel)
        triggerServerEvent("onOriginalModelRestored", resourceRoot, vehicle, originalModel)
    end
end)

outputDebugString("[Vehicle Variants Client] Script loaded successfully!")
