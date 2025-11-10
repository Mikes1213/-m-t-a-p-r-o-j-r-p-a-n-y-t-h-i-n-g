--[[
    Vehicle Variants Client Script for MTA:SA
    Handles loading custom models (DFF/TXD) on client side
]]

-- Store loaded custom models to avoid reloading
-- Format: [customID] = true or [originalModel_variant] = true
local loadedCustomModels = {}

-- Function to load custom model and replace original model (client-side only)
function loadCustomModel(customID, dffPath, txdPath, originalModel)
    -- Create unique key for this model variant
    local modelKey = originalModel .. "_" .. customID
    
    -- Check if already loaded
    if loadedCustomModels[modelKey] then
        return true, "Model już załadowany", customID
    end
    
    -- Load TXD file first (if provided)
    if txdPath then
        local txd = engineLoadTXD(txdPath, true)
        if txd then
            -- Try importing to custom ID first
            local txdImported = engineImportTXD(txd, customID)
            if not txdImported then
                -- If custom ID fails, try original model
                txdImported = engineImportTXD(txd, originalModel)
                if not txdImported then
                    outputDebugString("[Vehicle Variants Client] Warning: Failed to import TXD, continuing without it")
                end
            end
        else
            -- TXD loading failed, but we can continue without it
            outputDebugString("[Vehicle Variants Client] Warning: Failed to load TXD file: " .. txdPath .. ", continuing without it")
        end
    end
    
    -- Load DFF file
    if dffPath then
        outputDebugString("[Vehicle Variants Client] Attempting to load DFF: " .. dffPath)
        
        -- Try loading DFF with original model ID first (more reliable)
        local dff = engineLoadDFF(dffPath, originalModel)
        local replaced = false
        
        if dff then
            outputDebugString("[Vehicle Variants Client] DFF loaded successfully, attempting to replace model " .. originalModel)
            -- Try to replace original model directly
            replaced = engineReplaceModel(dff, originalModel)
            if replaced then
                outputDebugString("[Vehicle Variants Client] Successfully replaced model " .. originalModel)
                customID = originalModel
            else
                outputDebugString("[Vehicle Variants Client] Failed to replace model " .. originalModel .. ", trying custom ID " .. customID)
            end
        else
            outputDebugString("[Vehicle Variants Client] Failed to load DFF with original model ID, trying custom ID")
        end
        
        -- If that fails, try with custom ID
        if not replaced then
            dff = engineLoadDFF(dffPath, customID)
            if dff then
                outputDebugString("[Vehicle Variants Client] DFF loaded with custom ID, attempting to replace model " .. customID)
                replaced = engineReplaceModel(dff, customID)
                if replaced then
                    outputDebugString("[Vehicle Variants Client] Successfully replaced model " .. customID)
                else
                    outputDebugString("[Vehicle Variants Client] Failed to replace model " .. customID)
                end
            else
                outputDebugString("[Vehicle Variants Client] Failed to load DFF with custom ID " .. customID)
            end
        end
        
        if not replaced then
            return false, "Nie udało się zastąpić modelu DFF - sprawdź czy plik istnieje i jest poprawny"
        end
    end
    
    loadedCustomModels[modelKey] = true
    return true, "Custom model załadowany pomyślnie", customID
end

-- Receive custom model data from server and load it
addEvent("loadCustomModelVariant", true)
addEventHandler("loadCustomModelVariant", root, function(customID, dffPath, txdPath, vehicle, originalModel)
    if not customID or not dffPath or not vehicle or not originalModel then
        outputDebugString("[Vehicle Variants Client] Missing parameters: customID=" .. tostring(customID) .. ", dffPath=" .. tostring(dffPath) .. ", vehicle=" .. tostring(vehicle) .. ", originalModel=" .. tostring(originalModel))
        return
    end
    
    -- Ensure paths are relative to resource (add :resourceName if needed)
    local resourceName = getResourceName(getThisResource())
    outputDebugString("[Vehicle Variants Client] Resource name: " .. resourceName)
    
    if not string.find(dffPath, ":") then
        dffPath = ":" .. resourceName .. "/" .. dffPath
    end
    if txdPath and not string.find(txdPath, ":") then
        txdPath = ":" .. resourceName .. "/" .. txdPath
    end
    
    outputDebugString("[Vehicle Variants Client] Loading model - DFF: " .. dffPath .. ", TXD: " .. tostring(txdPath) .. ", CustomID: " .. customID .. ", OriginalModel: " .. originalModel)
    
    -- Load the custom model
    local success, message, finalModelID = loadCustomModel(customID, dffPath, txdPath, originalModel)
    
    if success and isElement(vehicle) then
        -- Use the final model ID (may be customID or originalModel if replacement failed)
        finalModelID = finalModelID or customID
        
        outputDebugString("[Vehicle Variants Client] Model loaded successfully, setting vehicle model to: " .. finalModelID)
        
        -- Set vehicle model to the final model ID
        setElementModel(vehicle, finalModelID)
        triggerServerEvent("onCustomModelLoaded", resourceRoot, vehicle, finalModelID, true, message)
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
