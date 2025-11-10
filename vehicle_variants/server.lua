-- server.lua - Server-side vehicle variants management
-- Autor: P.M (Piorun)

-- Tabela do przechowywania wariantów pojazdów
local vehicleVariants = {}

-- Funkcja do ustawienia wariantów pojazdu
function setVehicleVariants(vehicle, variant1, variant2)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end
    
    variant1 = variant1 or 255
    variant2 = variant2 or 255
    
    -- Ustaw warianty
    setVehicleVariant(vehicle, variant1, variant2)
    
    -- Zapisz w tabeli
    vehicleVariants[vehicle] = {
        variant1 = variant1,
        variant2 = variant2
    }
    
    -- Trigger event dla klientów
    triggerClientEvent("onVehicleVariantsChanged", vehicle, variant1, variant2)
    
    outputDebugString("[Vehicle Variants] Ustawiono warianty dla pojazdu: " .. getVehicleName(vehicle) .. " (" .. variant1 .. ", " .. variant2 .. ")")
    return true
end

-- Funkcja do pobrania wariantów pojazdu
function getVehicleVariants(vehicle)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end
    
    local variant1, variant2 = getVehicleVariant(vehicle)
    return variant1, variant2
end

-- Funkcja do losowego ustawienia wariantów
function randomizeVehicleVariants(vehicle)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end
    
    local variant1 = math.random(0, 255)
    local variant2 = math.random(0, 255)
    
    return setVehicleVariants(vehicle, variant1, variant2)
end

-- Funkcja do ustawienia konkretnej części pojazdu
function setVehiclePartVariant(vehicle, partIndex, enabled)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end
    
    local variant1, variant2 = getVehicleVariant(vehicle)
    
    if partIndex >= 0 and partIndex <= 15 then
        -- Modyfikuj variant1
        local bitValue = 2^partIndex
        if enabled then
            variant1 = math.max(0, variant1 - bitValue)
        else
            if (variant1 % (bitValue * 2)) >= bitValue then
                variant1 = variant1 + bitValue
            end
        end
    elseif partIndex >= 16 and partIndex <= 31 then
        -- Modyfikuj variant2
        local bitIndex = partIndex - 16
        local bitValue = 2^bitIndex
        if enabled then
            variant2 = math.max(0, variant2 - bitValue)
        else
            if (variant2 % (bitValue * 2)) >= bitValue then
                variant2 = variant2 + bitValue
            end
        end
    else
        return false
    end
    
    return setVehicleVariants(vehicle, variant1, variant2)
end

-- Command: /variant [variant1] [variant2]
addCommandHandler("variant", function(player, cmd, var1, var2)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    if not var1 then
        local v1, v2 = getVehicleVariant(vehicle)
        outputChatBox("📊 Aktualne warianty: Variant1 = " .. v1 .. ", Variant2 = " .. v2, player, 100, 255, 100)
        
        -- Wyświetl opis
        local description = VehicleVariants.getVariantDescription(v1, v2)
        if #description > 0 then
            outputChatBox("🔧 Zainstalowane części: " .. table.concat(description, ", "), player, 100, 200, 255)
        else
            outputChatBox("🔧 Pojazd bez dodatków (czysty)", player, 100, 200, 255)
        end
        return
    end
    
    var1 = tonumber(var1) or 255
    var2 = tonumber(var2) or 255
    
    if var1 < 0 or var1 > 255 or var2 < 0 or var2 > 255 then
        outputChatBox("❌ Wartości muszą być w zakresie 0-255!", player, 255, 0, 0)
        return
    end
    
    setVehicleVariants(vehicle, var1, var2)
    outputChatBox("✅ Ustawiono warianty pojazdu: " .. var1 .. ", " .. var2, player, 100, 255, 100)
end)

-- Command: /randomvariant
addCommandHandler("randomvariant", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    randomizeVehicleVariants(vehicle)
    local v1, v2 = getVehicleVariant(vehicle)
    outputChatBox("🎲 Wylosowano warianty: " .. v1 .. ", " .. v2, player, 100, 255, 100)
end)

-- Command: /cleanvariant
addCommandHandler("cleanvariant", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    setVehicleVariants(vehicle, 255, 255)
    outputChatBox("✅ Usunięto wszystkie dodatki z pojazdu (czysty pojazd)", player, 100, 255, 100)
end)

-- Command: /sportvariant
addCommandHandler("sportvariant", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    setVehicleVariants(vehicle, 0, 0)
    outputChatBox("🏎️ Ustawiono sportowy wariant (wszystkie dodatki)", player, 100, 255, 100)
end)

-- Command: /variantpart [partIndex] [0/1]
addCommandHandler("variantpart", function(player, cmd, partIndex, enabled)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    if not partIndex or not enabled then
        outputChatBox("❌ Użycie: /variantpart [indeks części 0-17] [0/1]", player, 255, 200, 0)
        outputChatBox("📋 Dostępne części:", player, 100, 200, 255)
        outputChatBox("0=Spoiler, 1=Hood, 2=Roof, 3=SideSkirt, 4=Lamps, 5=Nitro", player, 100, 200, 255)
        outputChatBox("6=Exhaust, 7=Wheels, 8=Stereo, 9=Hydraulics", player, 100, 200, 255)
        outputChatBox("10=FrontBumper, 11=RearBumper, 12=VentRight, 13=VentLeft", player, 100, 200, 255)
        outputChatBox("16=TaxiLight, 17=SplitWings", player, 100, 200, 255)
        return
    end
    
    partIndex = tonumber(partIndex)
    enabled = tonumber(enabled) == 1
    
    if setVehiclePartVariant(vehicle, partIndex, enabled) then
        outputChatBox("✅ " .. (enabled and "Włączono" or "Wyłączono") .. " część nr " .. partIndex, player, 100, 255, 100)
    else
        outputChatBox("❌ Nieprawidłowy indeks części!", player, 255, 0, 0)
    end
end)

-- Event: Zapisz warianty przy respawn pojazdu
addEventHandler("onVehicleRespawn", root, function()
    if vehicleVariants[source] then
        local data = vehicleVariants[source]
        setVehicleVariant(source, data.variant1, data.variant2)
    end
end)

-- Event: Usuń dane przy zniszczeniu pojazdu
addEventHandler("onVehicleExplode", root, function()
    vehicleVariants[source] = nil
end)

-- Funkcja pomocnicza do spawnu pojazdu z wariantami
function createVehicleWithVariants(model, x, y, z, rx, ry, rz, variant1, variant2)
    local vehicle = createVehicle(model, x, y, z, rx, ry, rz)
    if vehicle then
        setVehicleVariants(vehicle, variant1 or 255, variant2 or 255)
    end
    return vehicle
end

-- Testowy spawn pojazdu z wariantami (możesz to usunąć w produkcji)
addCommandHandler("testvariant", function(player)
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicleWithVariants(562, x + 3, y, z + 1, 0, 0, 0, 0, 0) -- Elegy z wszystkimi dodatkami
    outputChatBox("✅ Stworzono testowy pojazd Elegy z wariantami (0, 0)", player, 100, 255, 100)
end)

-- Server-side event handlers dla client GUI
addEvent("onClientRequestPartChange", true)
addEventHandler("onClientRequestPartChange", root, function(partIndex, enabled)
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setVehiclePartVariant(vehicle, partIndex, enabled)
        outputChatBox("✅ " .. (enabled and "Włączono" or "Wyłączono") .. " część nr " .. partIndex, client, 100, 255, 100)
    end
end)

addEvent("onClientRequestRandomVariant", true)
addEventHandler("onClientRequestRandomVariant", root, function()
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        randomizeVehicleVariants(vehicle)
        local v1, v2 = getVehicleVariant(vehicle)
        outputChatBox("🎲 Wylosowano warianty: " .. v1 .. ", " .. v2, client, 100, 255, 100)
    end
end)

addEvent("onClientRequestCleanVariant", true)
addEventHandler("onClientRequestCleanVariant", root, function()
    local vehicle = getPedOccupiedVehicle(client)
    if vehicle then
        setVehicleVariants(vehicle, 255, 255)
        outputChatBox("✅ Usunięto wszystkie dodatki z pojazdu", client, 100, 255, 100)
    end
end)

outputDebugString("[Vehicle Variants] System wariantów pojazdów załadowany!")
