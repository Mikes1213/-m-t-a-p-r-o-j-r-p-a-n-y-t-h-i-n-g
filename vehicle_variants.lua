--[[
    Vehicle Variants Script for MTA:SA
    Allows players and admins to set vehicle variants
    
    Vehicle variants change visual aspects of vehicles like:
    - Body styles
    - Spoilers
    - Hoods
    - Roofs
    - etc.
]]

-- Configuration
local ADMIN_ACL = "Admin" -- ACL group that can use admin commands
local ENABLE_PLAYER_COMMANDS = true -- Allow players to use /setvariant command

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
    
    -- Set the variant
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

outputDebugString("[Vehicle Variants] Script loaded successfully!")
