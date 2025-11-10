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
            -- Try importing to custom ID first
            local txdImported = engineImportTXD(txd, customID)
            if not txdImported then
                -- If custom ID fails, try original model
                txdImported = engineImportTXD(txd, originalModel)
                if not txdImported then
                    outputChatBox("[WARNING] Failed to import TXD, continuing without it", 255, 165, 0)
                    outputDebugString("[Vehicle Variants Client] Warning: Failed to import TXD, continuing without it")
                else
                    outputChatBox("[SUCCESS] TXD imported to model " .. originalModel, 0, 255, 0)
                end
            else
                outputChatBox("[SUCCESS] TXD imported to model " .. customID, 0, 255, 0)
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
        
        -- IMPORTANT: Try custom ID FIRST to avoid changing all vehicles of this type
        -- Only use original model as fallback if custom ID doesn't work
        -- Try to free the custom ID first (ignore if it fails)
        engineFreeModel(customID)
        
        local dff = engineLoadDFF(dffPath, customID)
        local replaced = false
        
        if dff then
            outputChatBox("[DEBUG] DFF loaded with custom ID! Trying to replace model " .. customID, 255, 255, 0)
            outputDebugString("[Vehicle Variants Client] DFF loaded successfully with custom ID, attempting to replace model " .. customID)
            -- Try to replace custom ID model (this won't affect original model)
            replaced = engineReplaceModel(dff, customID)
            if replaced then
                outputChatBox("[SUCCESS] Custom model " .. customID .. " loaded!", 0, 255, 0)
                outputDebugString("[Vehicle Variants Client] Successfully replaced model " .. customID)
                -- Keep customID, don't change to originalModel
            else
                outputChatBox("[WARNING] Failed to replace custom model " .. customID .. ", trying original model as fallback", 255, 165, 0)
                outputDebugString("[Vehicle Variants Client] Failed to replace custom model " .. customID .. ", trying original model")
            end
        else
            outputChatBox("[WARNING] Failed to load DFF with custom ID " .. customID .. ", trying original model", 255, 165, 0)
            outputDebugString("[Vehicle Variants Client] Failed to load DFF with custom ID, trying original model")
        end
        
        -- Fallback: Only use original model if custom ID completely fails
        -- WARNING: This will change ALL vehicles of this type!
        if not replaced then
            outputChatBox("[WARNING] Using original model as fallback - this will affect ALL vehicles of this type!", 255, 165, 0)
            dff = engineLoadDFF(dffPath, originalModel)
            if dff then
                outputChatBox("[DEBUG] DFF loaded with original model! Trying to replace...", 255, 255, 0)
                outputDebugString("[Vehicle Variants Client] DFF loaded with original model ID, attempting to replace model " .. originalModel)
                replaced = engineReplaceModel(dff, originalModel)
                if replaced then
                    outputChatBox("[SUCCESS] Model " .. originalModel .. " replaced (fallback mode)", 0, 255, 0)
                    outputDebugString("[Vehicle Variants Client] Successfully replaced model " .. originalModel .. " (fallback)")
                    customID = originalModel -- Use original model ID since custom failed
                else
                    outputChatBox("[ERROR] Failed to replace model " .. originalModel, 255, 0, 0)
                    outputDebugString("[Vehicle Variants Client] Failed to replace model " .. originalModel)
                end
            else
                outputChatBox("[ERROR] Failed to load DFF with original model ID - file may not exist: " .. dffPath, 255, 0, 0)
                outputDebugString("[Vehicle Variants Client] Failed to load DFF with original model ID")
            end
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
        
        outputChatBox("[SUCCESS] Model loaded! Setting vehicle to model: " .. finalModelID, 0, 255, 0)
        outputDebugString("[Vehicle Variants Client] Model loaded successfully, setting vehicle model to: " .. finalModelID)
        
        -- Set vehicle model to the final model ID
        setElementModel(vehicle, finalModelID)
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
        local currentModel = getElementModel(vehicle)
        
        -- If vehicle is using custom ID (not original model), just change it back
        -- No need to restore because original model wasn't changed
        if currentModel ~= originalModel then
            -- Vehicle is using custom ID, just change model back
            setElementModel(vehicle, originalModel)
        else
            -- Vehicle is using original model ID, might have been replaced
            -- Restore original model (only affects if it was actually replaced)
            engineRestoreModel(originalModel)
            setElementModel(vehicle, originalModel)
        end
        
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
