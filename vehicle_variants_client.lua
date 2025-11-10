--[[
    Vehicle Variants Client Script for MTA:SA
    Handles loading custom models (DFF/TXD) on client side
]]

-- Store loaded custom models to avoid reloading
-- Format: [customID] = true or [originalModel_variant] = true
local loadedCustomModels = {}

-- Function to load custom model and replace original model (client-side only)
function loadCustomModel(customID, dffPath, txdPath, originalModel)
    outputChatBox("[DEBUG] loadCustomModel called", 255, 255, 0)
    
    -- Create unique key for this model variant
    local modelKey = originalModel .. "_" .. customID
    
    -- Check if already loaded
    if loadedCustomModels[modelKey] then
        outputChatBox("[INFO] Model already loaded", 0, 255, 255)
        return true, "Model już załadowany", customID
    end
    
    outputChatBox("[DEBUG] Loading TXD first...", 255, 255, 0)
    
    -- Load TXD file first (if provided)
    if txdPath then
        outputChatBox("[DEBUG] TXD path: " .. txdPath, 255, 255, 0)
        local txd = engineLoadTXD(txdPath, true)
        if txd then
            outputChatBox("[DEBUG] TXD loaded, importing...", 255, 255, 0)
            -- Import TXD to original model (we use original model ID with replaced DFF)
            local txdImported = engineImportTXD(txd, originalModel)
            if txdImported then
                outputChatBox("[SUCCESS] TXD imported to model " .. originalModel, 0, 255, 0)
            else
                outputChatBox("[WARNING] Failed to import TXD, continuing without it", 255, 165, 0)
                outputDebugString("[Vehicle Variants Client] Warning: Failed to import TXD, continuing without it")
            end
        else
            -- TXD loading failed, but we can continue without it
            outputChatBox("[WARNING] Failed to load TXD file: " .. txdPath .. ", continuing without it", 255, 165, 0)
            outputDebugString("[Vehicle Variants Client] Warning: Failed to load TXD file: " .. txdPath .. ", continuing without it")
        end
    else
        outputChatBox("[INFO] No TXD file provided", 255, 255, 0)
    end
    
    outputChatBox("[DEBUG] Now loading DFF...", 255, 255, 0)
    
    -- Load DFF file
    if dffPath then
        outputChatBox("[DEBUG] Attempting to load DFF: " .. dffPath, 255, 255, 0)
        outputDebugString("[Vehicle Variants Client] Attempting to load DFF: " .. dffPath)
        
        -- NOTE: In MTA:SA, we cannot use custom IDs as vehicle models with setElementModel
        -- We must use the original model ID (560) with engineReplaceModel
        -- This will change ALL vehicles of this type, but it's the only way it works
        local dff = engineLoadDFF(dffPath, originalModel)
        local replaced = false
        
        if dff then
            outputChatBox("[DEBUG] DFF loaded! Replacing model " .. originalModel, 255, 255, 0)
            outputDebugString("[Vehicle Variants Client] DFF loaded successfully, attempting to replace model " .. originalModel)
            -- Replace original model (this affects ALL vehicles of this type)
            replaced = engineReplaceModel(dff, originalModel)
            if replaced then
                outputChatBox("[SUCCESS] Model " .. originalModel .. " replaced!", 0, 255, 0)
                outputDebugString("[Vehicle Variants Client] Successfully replaced model " .. originalModel)
                customID = originalModel -- Use original model ID
            else
                outputChatBox("[ERROR] Failed to replace model " .. originalModel, 255, 0, 0)
                outputDebugString("[Vehicle Variants Client] Failed to replace model " .. originalModel)
            end
        else
            outputChatBox("[ERROR] Failed to load DFF - file may not exist: " .. dffPath, 255, 0, 0)
            outputDebugString("[Vehicle Variants Client] Failed to load DFF with original model ID")
        end
        
        if not replaced then
            return false, "Nie udało się zastąpić modelu DFF - sprawdź czy plik istnieje: " .. dffPath
        end
    end
    
    loadedCustomModels[modelKey] = true
    return true, "Custom model załadowany pomyślnie", customID
end

-- Receive custom model data from server and load it
addEvent("loadCustomModelVariant", true)
addEventHandler("loadCustomModelVariant", root, function(customID, dffPath, txdPath, vehicle, originalModel)
    outputChatBox("[DEBUG] Event received! customID=" .. tostring(customID) .. ", dffPath=" .. tostring(dffPath), 255, 255, 0)
    
    if not customID or not dffPath or not vehicle or not originalModel then
        outputChatBox("[ERROR] Missing parameters!", 255, 0, 0)
        outputDebugString("[Vehicle Variants Client] Missing parameters: customID=" .. tostring(customID) .. ", dffPath=" .. tostring(dffPath) .. ", vehicle=" .. tostring(vehicle) .. ", originalModel=" .. tostring(originalModel))
        return
    end
    
    -- Ensure paths are relative to resource (add :resourceName if needed)
    local resourceName = getResourceName(getThisResource())
    outputChatBox("[DEBUG] Resource name: " .. resourceName, 255, 255, 0)
    outputDebugString("[Vehicle Variants Client] Resource name: " .. resourceName)
    
    if not string.find(dffPath, ":") then
        dffPath = ":" .. resourceName .. "/" .. dffPath
    end
    if txdPath and not string.find(txdPath, ":") then
        txdPath = ":" .. resourceName .. "/" .. txdPath
    end
    
    outputChatBox("[DEBUG] Final paths - DFF: " .. dffPath .. ", TXD: " .. tostring(txdPath), 255, 255, 0)
    outputDebugString("[Vehicle Variants Client] Loading model - DFF: " .. dffPath .. ", TXD: " .. tostring(txdPath) .. ", CustomID: " .. customID .. ", OriginalModel: " .. originalModel)
    
    -- Load the custom model
    local success, message, finalModelID = loadCustomModel(customID, dffPath, txdPath, originalModel)
    
    if success and isElement(vehicle) then
        -- Use the final model ID (may be customID or originalModel if replacement failed)
        finalModelID = finalModelID or customID
        
        outputChatBox("[SUCCESS] Model loaded! Final Model ID: " .. finalModelID, 0, 255, 0)
        outputChatBox("[DEBUG] Current vehicle model before change: " .. getElementModel(vehicle), 255, 255, 0)
        outputDebugString("[Vehicle Variants Client] Model loaded successfully, setting vehicle model to: " .. finalModelID)
        
        -- Don't try to change model on client side - server will do it
        -- Client-side setElementModel doesn't work for custom vehicle IDs
        -- Just notify server that model is loaded and ready
        triggerServerEvent("onCustomModelLoaded", resourceRoot, vehicle, finalModelID, true, message)
    else
        outputChatBox("[ERROR] Failed: " .. tostring(message), 255, 0, 0)
        outputDebugString("[Vehicle Variants Client] Failed to load model: " .. tostring(message))
        triggerServerEvent("onCustomModelLoaded", resourceRoot, vehicle, customID, false, message)
    end
end)

-- Receive request to restore original model
addEvent("restoreOriginalModelVariant", true)
addEventHandler("restoreOriginalModelVariant", root, function(vehicle, originalModel)
    if isElement(vehicle) and originalModel then
        -- Restore the original model DFF (this restores the model for all vehicles of this type)
        engineRestoreModel(originalModel)
        
        -- Vehicle already uses original model ID, no need to change it
        -- Just restore the DFF and it will show the original model
        
        -- Clear loaded custom models for this original model so we can reload them later
        for modelKey, _ in pairs(loadedCustomModels) do
            if string.find(modelKey, "^" .. originalModel .. "_") then
                loadedCustomModels[modelKey] = nil
            end
        end
        
        triggerServerEvent("onOriginalModelRestored", resourceRoot, vehicle, originalModel)
    end
end)

outputDebugString("[Vehicle Variants Client] Script loaded successfully!")
