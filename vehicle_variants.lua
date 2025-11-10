--[[
    Vehicle Variants Script for MTA:SA
    Allows players and admins to set vehicle variants
    
    Vehicle variants change visual aspects of vehicles like:
    - Body styles
    - Spoilers
    - Hoods
    - Roofs
    - Custom models (DFF/TXD) using EngineFreeModel
    - etc.
]]

-- Configuration
local ADMIN_ACL = "Admin" -- ACL group that can use admin commands
local ENABLE_PLAYER_COMMANDS = true -- Allow players to use /setvariant command

-- Custom model variants configuration
-- Format: [originalModel] = { [variant1] = { customID = number, dff = "path/to/model.dff", txd = "path/to/model.txd" } }
local customModelVariants = {
    -- Sultan (560) z custom modelem bez dachu
    [560] = {
        [1] = { 
            customID = 18000, 
            dff = "models/sultan_nodach.dff", 
            txd = "models/sultan_nodach.txd" 
        }
    }
    -- Możesz dodać więcej pojazdów tutaj:
    -- [411] = {  -- Infernus
    --     [1] = { customID = 18001, dff = "models/infernus_custom.dff", txd = "models/infernus_custom.txd" }
    -- }
}

-- Store original models for vehicles (to restore when variant = 0)
local vehicleOriginalModels = {}

-- Helper function to check if player is admin
function isPlayerAdmin(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    local account = getPlayerAccount(player)
    if not account then
        return false
    end
    return isObjectInACLGroup("user." .. getAccountName(account), aclGetGroup(ADMIN_ACL))
end

-- Function to replace vehicle with custom ID vehicle
function replaceVehicleWithCustomModel(vehicle, customModelID, dffPath, txdPath, originalModel)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false, "Invalid vehicle"
    end
    
    -- First, load custom model on all clients
    -- Then create vehicle with custom ID (clients need model loaded first)
    triggerClientEvent(root, "loadCustomModelForVehicle", resourceRoot, customModelID, dffPath, txdPath)
    
    -- Wait a bit for model to load on clients, then create vehicle
    setTimer(function()
        if not isElement(vehicle) then
            return
        end
        
        -- Save all vehicle properties
        local x, y, z = getElementPosition(vehicle)
        local rx, ry, rz = getElementRotation(vehicle)
        local health = getElementHealth(vehicle)
        local color1, color2, color3, color4 = getVehicleColor(vehicle)
        local paintjob = getVehiclePaintjob(vehicle)
        local plateText = getVehiclePlateText(vehicle)
        local locked = isVehicleLocked(vehicle)
        local engineState = getVehicleEngineState(vehicle)
        -- Note: getVehicleLightState requires light ID, so we skip saving lights state
        -- Lights are usually managed automatically by the game
        local doorStates = {}
        for i = 0, 5 do
            doorStates[i] = getVehicleDoorState(vehicle, i)
        end
        local wheelStates = {}
        for i = 0, 3 do
            wheelStates[i] = getVehicleWheelStates(vehicle, i)
        end
        local panelStates = {}
        for i = 0, 6 do
            panelStates[i] = getVehiclePanelState(vehicle, i)
        end
        
        -- Save vehicle occupants
        local driver = getVehicleController(vehicle)
        local passengers = {}
        for i = 0, getVehicleMaxPassengers(vehicle) do
            local passenger = getVehicleOccupant(vehicle, i)
            if passenger then
                passengers[i] = passenger
            end
        end
        
        -- Save element data
        local allData = {}
        for key, value in pairs(getAllElementData(vehicle)) do
            allData[key] = value
        end
        
        -- Store original model for restoration
        if not vehicleOriginalModels[vehicle] then
            vehicleOriginalModels[vehicle] = originalModel
        end
        
        -- Create new vehicle with original model
        -- Note: createVehicle cannot use custom ID on server side
        -- We'll use original model and replace DFF on clients (affects all vehicles of this type)
        local newVehicle = createVehicle(originalModel, x, y, z, rx, ry, rz)
        
        if not newVehicle then
            outputDebugString("[Vehicle Variants] ERROR: Failed to create vehicle with original model!")
            return
        end
        
        -- Load custom model for original model (this will affect all vehicles of this type)
        -- But at least this specific vehicle will have the custom model
        triggerClientEvent(root, "loadCustomModelVariant", resourceRoot, 
            customModelID, dffPath, txdPath, newVehicle, originalModel)
        
        -- Restore all properties
        setElementHealth(newVehicle, health)
        setVehicleColor(newVehicle, color1, color2, color3, color4)
        if paintjob then
            setVehiclePaintjob(newVehicle, paintjob)
        end
        setVehiclePlateText(newVehicle, plateText)
        setVehicleLocked(newVehicle, locked)
        setVehicleEngineState(newVehicle, engineState)
        -- Note: Lights state is not saved/restored (getVehicleLightState requires light ID)
        
        for i = 0, 5 do
            if doorStates[i] then
                setVehicleDoorState(newVehicle, i, doorStates[i])
            end
        end
        
        for i = 0, 3 do
            if wheelStates[i] then
                setVehicleWheelStates(newVehicle, i, wheelStates[i])
            end
        end
        
        for i = 0, 6 do
            if panelStates[i] then
                setVehiclePanelState(newVehicle, i, panelStates[i])
            end
        end
        
        -- Restore element data
        for key, value in pairs(allData) do
            setElementData(newVehicle, key, value)
        end
        
        -- Store original model for new vehicle
        vehicleOriginalModels[newVehicle] = originalModel
        
        -- Restore occupants
        if driver then
            warpPedIntoVehicle(driver, newVehicle, 0)
        end
        for seat, passenger in pairs(passengers) do
            if seat > 0 then
                warpPedIntoVehicle(passenger, newVehicle, seat)
            end
        end
        
        -- Destroy old vehicle
        destroyElement(vehicle)
        
        outputDebugString("[Vehicle Variants] Vehicle replaced successfully with model " .. getElementModel(newVehicle))
    end, 500, 1) -- Wait 500ms for model to load on clients
    
    return true, "Pojazd zamieniany na custom model..."
end

-- Function to apply custom model variant by replacing vehicle
function applyCustomModelVariant(vehicle, originalModel, variant1)
    -- Check if there's a custom model for this variant
    if not customModelVariants[originalModel] or not customModelVariants[originalModel][variant1] then
        return false, "Brak custom modelu dla tego wariantu"
    end
    
    local customModelData = customModelVariants[originalModel][variant1]
    
    -- Generate unique custom ID for this specific vehicle using element ID
    local vehicleID = 0
    local elementID = getElementID(vehicle)
    if elementID then
        vehicleID = tonumber(elementID) or 0
    end
    
    if vehicleID == 0 then
        local vehicleIDData = getElementData(vehicle, "vehicleID")
        if vehicleIDData then
            vehicleID = tonumber(vehicleIDData) or 0
        end
    end
    
    if vehicleID == 0 then
        local vehiclePointer = tostring(vehicle):match("%d+")
        vehicleID = (tonumber(vehiclePointer) or 0) % 1000
    end
    
    local uniqueCustomID = customModelData.customID + vehicleID
    
    outputDebugString("[Vehicle Variants] Replacing vehicle with custom ID: " .. uniqueCustomID)
    
    -- Replace vehicle with custom model
    local success, message, newVehicle = replaceVehicleWithCustomModel(
        vehicle, 
        uniqueCustomID, 
        customModelData.dff, 
        customModelData.txd, 
        originalModel
    )
    
    if success then
        return true, "Pojazd zamieniony na custom model", newVehicle
    else
        return false, message
    end
end

-- Handle confirmation from client that model was loaded
addEvent("onCustomModelLoaded", true)
addEventHandler("onCustomModelLoaded", root, function(vehicle, finalModelID, success, message)
    if success and isElement(vehicle) then
        outputDebugString("[Vehicle Variants] Custom model " .. finalModelID .. " loaded successfully")
        
        -- Try to change vehicle model to custom ID (if it's not original model)
        if finalModelID ~= vehicleOriginalModels[vehicle] then
            -- Wait a bit for model to be fully loaded
            setTimer(function()
                if isElement(vehicle) then
                    local currentModel = getElementModel(vehicle)
                    outputDebugString("[Vehicle Variants] Attempting to change vehicle model from " .. currentModel .. " to " .. finalModelID)
                    
                    -- Try to change model to custom ID
                    local modelChanged = setElementModel(vehicle, finalModelID)
                    local newModel = getElementModel(vehicle)
                    
                    outputDebugString("[Vehicle Variants] setElementModel(" .. finalModelID .. ") result: " .. tostring(modelChanged) .. ", new model: " .. newModel)
                    
                    if newModel == finalModelID then
                        outputDebugString("[Vehicle Variants] SUCCESS! Vehicle model changed to custom ID " .. finalModelID)
                    else
                        outputDebugString("[Vehicle Variants] WARNING: setElementModel failed - custom ID may not work for vehicles")
                        outputDebugString("[Vehicle Variants] Vehicle will use original model with replaced DFF (affects all vehicles of this type)")
                    end
                end
            end, 200, 1) -- Wait 200ms for model to be ready
        else
            outputDebugString("[Vehicle Variants] Using original model with replaced DFF (affects all vehicles of this type)")
        end
    else
        outputDebugString("[Vehicle Variants] Failed to load custom model: " .. tostring(message))
    end
end)

-- Function to restore original model by replacing vehicle back
function restoreOriginalModel(vehicle)
    if not vehicleOriginalModels[vehicle] then
        return false, "Brak zapisanego oryginalnego modelu"
    end
    
    local originalModel = vehicleOriginalModels[vehicle]
    
    -- Replace vehicle back to original model (same as replaceVehicleWithCustomModel but with original model)
    -- Save all vehicle properties (same as in replaceVehicleWithCustomModel)
    local x, y, z = getElementPosition(vehicle)
    local rx, ry, rz = getElementRotation(vehicle)
    local health = getElementHealth(vehicle)
    local color1, color2, color3, color4 = getVehicleColor(vehicle)
    local paintjob = getVehiclePaintjob(vehicle)
    local plateText = getVehiclePlateText(vehicle)
    local locked = isVehicleLocked(vehicle)
    local engineState = getVehicleEngineState(vehicle)
    -- Note: getVehicleLightState requires light ID, so we skip saving lights state
    
    local doorStates = {}
    for i = 0, 5 do
        doorStates[i] = getVehicleDoorState(vehicle, i)
    end
    
    local wheelStates = {}
    for i = 0, 3 do
        wheelStates[i] = getVehicleWheelStates(vehicle, i)
    end
    
    local panelStates = {}
    for i = 0, 6 do
        panelStates[i] = getVehiclePanelState(vehicle, i)
    end
    
    local driver = getVehicleController(vehicle)
    local passengers = {}
    for i = 0, getVehicleMaxPassengers(vehicle) do
        local passenger = getVehicleOccupant(vehicle, i)
        if passenger then
            passengers[i] = passenger
        end
    end
    
    local allData = {}
    for key, value in pairs(getAllElementData(vehicle)) do
        allData[key] = value
    end
    
    -- Create new vehicle with original model
    local newVehicle = createVehicle(originalModel, x, y, z, rx, ry, rz)
    
    if not newVehicle then
        return false, "Nie udało się przywrócić oryginalnego pojazdu"
    end
    
    -- Restore all properties (same as in replaceVehicleWithCustomModel)
    setElementHealth(newVehicle, health)
    setVehicleColor(newVehicle, color1, color2, color3, color4)
    if paintjob then
        setVehiclePaintjob(newVehicle, paintjob)
    end
    setVehiclePlateText(newVehicle, plateText)
    setVehicleLocked(newVehicle, locked)
    setVehicleEngineState(newVehicle, engineState)
    -- Note: Lights state is not saved/restored (getVehicleLightState requires light ID)
    
    for i = 0, 5 do
        if doorStates[i] then
            setVehicleDoorState(newVehicle, i, doorStates[i])
        end
    end
    
    for i = 0, 3 do
        if wheelStates[i] then
            setVehicleWheelStates(newVehicle, i, wheelStates[i])
        end
    end
    
    for i = 0, 6 do
        if panelStates[i] then
            setVehiclePanelState(newVehicle, i, panelStates[i])
        end
    end
    
    for key, value in pairs(allData) do
        setElementData(newVehicle, key, value)
    end
    
    -- Restore occupants
    if driver then
        warpPedIntoVehicle(driver, newVehicle, 0)
    end
    for seat, passenger in pairs(passengers) do
        if seat > 0 then
            warpPedIntoVehicle(passenger, newVehicle, seat)
        end
    end
    
    -- Restore original model on clients (if it was replaced)
    triggerClientEvent(root, "restoreOriginalModelVariant", resourceRoot, originalModel)
    
    -- Clear stored original model (new vehicle is already original)
    vehicleOriginalModels[newVehicle] = nil
    
    -- Destroy old vehicle
    destroyElement(vehicle)
    
    return true, "Przywrócono oryginalny model", newVehicle
end

-- Handle confirmation from client that original model was restored
addEvent("onOriginalModelRestored", true)
addEventHandler("onOriginalModelRestored", root, function(vehicle, originalModel)
    outputDebugString("[Vehicle Variants] Original model " .. originalModel .. " restored for vehicle")
end)

-- Function to set vehicle variant
function setVehicleVariantSafe(vehicle, variant1, variant2)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false, "Invalid vehicle"
    end
    
    -- Validate variant values (0-255)
    variant1 = tonumber(variant1) or 0
    variant2 = tonumber(variant2) or 0
    
    if variant1 < 0 or variant1 > 255 then
        return false, "Variant 1 must be between 0 and 255"
    end
    
    if variant2 < 0 or variant2 > 255 then
        return false, "Variant 2 must be between 0 and 255"
    end
    
    -- Get current/original model
    local currentModel = getElementModel(vehicle)
    local originalModel = vehicleOriginalModels[vehicle] or currentModel
    
    -- If variant1 is 0, restore original model (if it was changed)
    if variant1 == 0 then
        -- Always restore if we have stored original model
        if vehicleOriginalModels[vehicle] then
            local success, message, newVehicle = restoreOriginalModel(vehicle)
            if not success then
                return false, message
            end
            -- Set variant to 0,0 on new vehicle
            if newVehicle then
                setVehicleVariant(newVehicle, 0, variant2)
                return true, "Przywrócono oryginalny model", newVehicle
            else
                return true, "Przywrócono oryginalny model"
            end
        else
            -- No custom model was applied, just set variant normally
            setVehicleVariant(vehicle, 0, variant2)
            return true, "Vehicle variant set successfully"
        end
    else
        -- Check if there's a custom model for this variant
        if customModelVariants[originalModel] and customModelVariants[originalModel][variant1] then
            local success, message, newVehicle = applyCustomModelVariant(vehicle, originalModel, variant1)
            if not success then
                return false, message
            end
            -- Still set the game variant (for compatibility)
            if newVehicle then
                setVehicleVariant(newVehicle, variant1, variant2)
                return true, "Custom model variant zastosowany", newVehicle
            else
                setVehicleVariant(vehicle, variant1, variant2)
                return true, "Custom model variant zastosowany"
            end
        end
    end
    
    -- Set the standard variant (for vehicles without custom models)
    local success = setVehicleVariant(vehicle, variant1, variant2)
    
    if success then
        return true, "Vehicle variant set successfully"
    else
        return false, "Failed to set vehicle variant"
    end
end

-- Command for players/admins to set vehicle variant
function setVariantCommand(player, command, variant1, variant2)
    local vehicle = getPedOccupiedVehicle(player)
    
    if not vehicle then
        outputChatBox("Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    variant1 = tonumber(variant1)
    variant2 = tonumber(variant2)
    
    if not variant1 then
        outputChatBox("Użycie: /setvariant [wariant1] [wariant2]", player, 255, 255, 0)
        outputChatBox("Przykład: /setvariant 1 0", player, 255, 255, 0)
        return
    end
    
    variant2 = variant2 or 0
    
    local success, message = setVehicleVariantSafe(vehicle, variant1, variant2)
    
    if success then
        outputChatBox("Wariant pojazdu ustawiony: " .. variant1 .. ", " .. variant2, player, 0, 255, 0)
    else
        outputChatBox("Błąd: " .. message, player, 255, 0, 0)
    end
end

if ENABLE_PLAYER_COMMANDS then
    addCommandHandler("setvariant", setVariantCommand)
end

-- Admin command to set variant for any vehicle
function adminSetVariantCommand(player, command, vehicleID, variant1, variant2)
    if not isPlayerAdmin(player) then
        outputChatBox("Nie masz uprawnień do użycia tej komendy!", player, 255, 0, 0)
        return
    end
    
    vehicleID = tonumber(vehicleID)
    variant1 = tonumber(variant1)
    variant2 = tonumber(variant2)
    
    if not vehicleID or not variant1 then
        outputChatBox("Użycie: /asetvariant [ID pojazdu] [wariant1] [wariant2]", player, 255, 255, 0)
        return
    end
    
    local vehicle = getElementByID("vehicle" .. vehicleID)
    if not vehicle then
        vehicle = getVehicleByID(vehicleID)
    end
    
    if not vehicle or getElementType(vehicle) ~= "vehicle" then
        outputChatBox("Nie znaleziono pojazdu o ID: " .. vehicleID, player, 255, 0, 0)
        return
    end
    
    variant2 = variant2 or 0
    
    local success, message = setVehicleVariantSafe(vehicle, variant1, variant2)
    
    if success then
        outputChatBox("Wariant pojazdu #" .. vehicleID .. " ustawiony: " .. variant1 .. ", " .. variant2, player, 0, 255, 0)
    else
        outputChatBox("Błąd: " .. message, player, 255, 0, 0)
    end
end

addCommandHandler("asetvariant", adminSetVariantCommand)

-- Admin command to get current variant of a vehicle
function getVariantCommand(player, command, vehicleID)
    if not isPlayerAdmin(player) then
        outputChatBox("Nie masz uprawnień do użycia tej komendy!", player, 255, 0, 0)
        return
    end
    
    vehicleID = tonumber(vehicleID)
    
    local vehicle
    if vehicleID then
        vehicle = getElementByID("vehicle" .. vehicleID)
        if not vehicle then
            vehicle = getVehicleByID(vehicleID)
        end
    else
        vehicle = getPedOccupiedVehicle(player)
    end
    
    if not vehicle or getElementType(vehicle) ~= "vehicle" then
        outputChatBox("Nie znaleziono pojazdu!", player, 255, 0, 0)
        return
    end
    
    local variant1, variant2 = getVehicleVariant(vehicle)
    
    if variant1 and variant2 then
        outputChatBox("Wariant pojazdu: " .. variant1 .. ", " .. variant2, player, 0, 255, 255)
    else
        outputChatBox("Nie udało się odczytać wariantu pojazdu", player, 255, 0, 0)
    end
end

addCommandHandler("getvariant", getVariantCommand)

-- Function to set variant when vehicle is spawned (example)
function onVehicleSpawn(vehicle)
    -- You can customize this to set default variants for specific vehicles
    -- Example: Set variant for Infernus (model 411)
    local model = getElementModel(vehicle)
    
    -- Example: Set variant 1,0 for Infernus
    if model == 411 then
        setVehicleVariant(vehicle, 1, 0)
    end
    
    -- Add more vehicle-specific variants here
end

-- Uncomment to enable automatic variant setting on spawn
-- addEventHandler("onVehicleSpawn", root, onVehicleSpawn)

-- Export function for other resources
function setVehicleVariantExported(vehicle, variant1, variant2)
    return setVehicleVariantSafe(vehicle, variant1, variant2)
end

-- Export the function
addEvent("setVehicleVariantCustom", true)
addEventHandler("setVehicleVariantCustom", root, function(vehicle, variant1, variant2)
    if client then
        local success, message = setVehicleVariantSafe(vehicle, variant1, variant2)
        triggerClientEvent(client, "onVehicleVariantSet", resourceRoot, success, message)
    end
end)

-- Admin command to add custom model variant
function addCustomVariantCommand(player, command, modelID, variant1, customID, dffPath, txdPath)
    if not isPlayerAdmin(player) then
        outputChatBox("Nie masz uprawnień do użycia tej komendy!", player, 255, 0, 0)
        return
    end
    
    modelID = tonumber(modelID)
    variant1 = tonumber(variant1)
    customID = tonumber(customID)
    
    if not modelID or not variant1 or not customID or not dffPath then
        outputChatBox("Użycie: /addcustomvariant [modelID] [variant1] [customID] [ścieżka/do/model.dff] [ścieżka/do/model.txd]", player, 255, 255, 0)
        outputChatBox("Przykład: /addcustomvariant 560 1 18000 models/sultan_nodach.dff models/sultan_nodach.txd", player, 255, 255, 0)
        return
    end
    
    -- Initialize table if needed
    if not customModelVariants[modelID] then
        customModelVariants[modelID] = {}
    end
    
    -- Add custom variant
    customModelVariants[modelID][variant1] = {
        customID = customID,
        dff = dffPath,
        txd = txdPath or nil
    }
    
    outputChatBox("Dodano custom wariant: Model " .. modelID .. ", Wariant " .. variant1 .. " -> Custom ID " .. customID, player, 0, 255, 0)
    outputDebugString("[Vehicle Variants] Added custom variant: Model " .. modelID .. ", Variant " .. variant1 .. " -> Custom ID " .. customID)
end

addCommandHandler("addcustomvariant", addCustomVariantCommand)

-- Clean up when vehicle is destroyed
addEventHandler("onElementDestroy", root, function()
    if getElementType(source) == "vehicle" then
        vehicleOriginalModels[source] = nil
    end
end)

-- Function to get custom variant info
function getCustomVariantInfo(modelID, variant1)
    if customModelVariants[modelID] and customModelVariants[modelID][variant1] then
        return customModelVariants[modelID][variant1]
    end
    return nil
end

outputDebugString("[Vehicle Variants] Script loaded successfully!")
