--[[
    example_usage.lua
    
    Przykłady użycia systemu Vehicle Variants w innych zasobach
    Ten plik pokazuje jak korzystać z exportowanych funkcji
    
    UWAGA: Ten plik NIE jest ładowany przez resource!
    Jest to tylko przewodnik/dokumentacja dla deweloperów.
]]

-- ========================================
-- PRZYKŁAD 1: Podstawowe użycie
-- ========================================

-- Stwórz pojazd i ustaw warianty
function example1_basicUsage()
    local x, y, z = 0, 0, 3
    local vehicle = createVehicle(562, x, y, z) -- Elegy
    
    -- Ustaw wszystkie dodatki
    exports.vehicle_variants:setVehicleVariants(vehicle, 0, 0)
    
    -- Lub czysty pojazd (bez dodatków)
    exports.vehicle_variants:setVehicleVariants(vehicle, 255, 255)
end

-- ========================================
-- PRZYKŁAD 2: System dealerów pojazdów
-- ========================================

-- Dealer z różnymi wersjami pojazdów
local dealershipVehicles = {
    {model = 562, name = "Elegy Standard", variant1 = 255, variant2 = 255, price = 50000},
    {model = 562, name = "Elegy Sport", variant1 = 0, variant2 = 0, price = 75000},
    {model = 562, name = "Elegy Custom", variant1 = 15, variant2 = 255, price = 65000},
}

function example2_dealership(player, vehicleIndex)
    if not dealershipVehicles[vehicleIndex] then return end
    
    local vehData = dealershipVehicles[vehicleIndex]
    local x, y, z = getElementPosition(player)
    
    -- Stwórz pojazd z wariantami
    local vehicle = createVehicle(vehData.model, x + 2, y, z)
    exports.vehicle_variants:setVehicleVariants(vehicle, vehData.variant1, vehData.variant2)
    
    outputChatBox("Zakupiono: " .. vehData.name .. " za $" .. vehData.price, player, 0, 255, 0)
end

-- ========================================
-- PRZYKŁAD 3: System tuningu
-- ========================================

-- Menu tuningu w warsztacie
local tuningPrices = {
    [0] = {name = "Spoiler", price = 500},
    [1] = {name = "Maska", price = 300},
    [2] = {name = "Dach", price = 400},
    [6] = {name = "Wydech", price = 800},
    [10] = {name = "Zderzak przedni", price = 600},
    [11] = {name = "Zderzak tylny", price = 600},
}

function example3_tuningShop(player, partIndex, action)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Musisz być w pojeździe!", player, 255, 0, 0)
        return
    end
    
    if not tuningPrices[partIndex] then
        outputChatBox("Nieznana część!", player, 255, 0, 0)
        return
    end
    
    local partData = tuningPrices[partIndex]
    local playerMoney = getPlayerMoney(player)
    
    if action == "install" and playerMoney >= partData.price then
        -- Tutaj użyj funkcji z server.lua aby zmienić konkretną część
        -- (setVehiclePartVariant jest funkcją wewnętrzną, więc użyj komend lub dodaj export)
        takePlayerMoney(player, partData.price)
        outputChatBox("Zainstalowano: " .. partData.name .. " za $" .. partData.price, player, 0, 255, 0)
    else
        outputChatBox("Nie masz wystarczająco pieniędzy! Potrzebujesz $" .. partData.price, player, 255, 0, 0)
    end
end

-- ========================================
-- PRZYKŁAD 4: Randomizacja dla różnorodności
-- ========================================

-- Spawn pojazdów z losowymi wariantami dla realizmu
function example4_randomSpawn()
    local spawnPoints = {
        {x = 1000, y = 2000, z = 10, model = 562},
        {x = 1100, y = 2000, z = 10, model = 565},
        {x = 1200, y = 2000, z = 10, model = 559},
    }
    
    for _, spawn in ipairs(spawnPoints) do
        local vehicle = createVehicle(spawn.model, spawn.x, spawn.y, spawn.z)
        
        -- Losuj warianty dla różnorodności
        exports.vehicle_variants:randomizeVehicleVariants(vehicle)
    end
end

-- ========================================
-- PRZYKŁAD 5: System nagród/achievement
-- ========================================

-- Nagroda za osiągnięcie - ekskluzywny pojazd
function example5_achievementReward(player)
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(562, x + 2, y, z)
    
    -- Unikalny wariant jako nagroda
    exports.vehicle_variants:setVehicleVariants(vehicle, 0, 0) -- Pełne wyposażenie
    
    -- Ustaw pojazd jako własność gracza
    setElementData(vehicle, "owner", getAccountName(getPlayerAccount(player)))
    setElementData(vehicle, "special_reward", true)
    
    outputChatBox("🏆 Gratulacje! Otrzymujesz ekskluzywnego Elegy!", player, 255, 215, 0)
end

-- ========================================
-- PRZYKŁAD 6: Event race z określonymi wariantami
-- ========================================

function example6_raceEvent()
    local racePlayers = getElementsByType("player")
    local startX, startY, startZ = 2000, 1500, 10
    
    for i, player in ipairs(racePlayers) do
        local vehicle = createVehicle(411, startX, startY + (i * 5), startZ) -- Infernus
        
        -- Wszystkie pojazdy wyścigowe mają te same warianty dla uczciwości
        exports.vehicle_variants:setVehicleVariants(vehicle, 0, 0)
        
        warpPedIntoVehicle(player, vehicle)
    end
    
    outputChatBox("🏁 Wyścig rozpocznie się za 10 sekund! Wszystkie pojazdy są identyczne!", root, 255, 255, 0)
end

-- ========================================
-- PRZYKŁAD 7: System level-up
-- ========================================

-- Im wyższy level gracza, tym więcej może customizować
local playerLevelVariants = {
    [1] = {variant1 = 255, variant2 = 255}, -- Brak dodatków
    [5] = {variant1 = 240, variant2 = 255}, -- Kilka podstawowych
    [10] = {variant1 = 200, variant2 = 255}, -- Więcej opcji
    [20] = {variant1 = 100, variant2 = 200}, -- Dużo opcji
    [50] = {variant1 = 0, variant2 = 0},     -- Wszystko dostępne
}

function example7_levelBasedCustomization(player, vehicle)
    local playerLevel = getElementData(player, "level") or 1
    
    -- Znajdź odpowiedni wariant dla poziomu gracza
    local availableVariant = playerLevelVariants[1]
    for level, variant in pairs(playerLevelVariants) do
        if playerLevel >= level then
            availableVariant = variant
        end
    end
    
    exports.vehicle_variants:setVehicleVariants(vehicle, availableVariant.variant1, availableVariant.variant2)
    outputChatBox("Customizacja pojazdu dostosowana do twojego poziomu (" .. playerLevel .. ")", player, 0, 255, 255)
end

-- ========================================
-- PRZYKŁAD 8: Sprawdzanie i kopiowanie wariantów
-- ========================================

function example8_copyVariants(sourceVehicle, targetVehicle)
    -- Pobierz warianty z jednego pojazdu
    local variant1, variant2 = exports.vehicle_variants:getVehicleVariants(sourceVehicle)
    
    if variant1 then
        -- Skopiuj do drugiego pojazdu
        exports.vehicle_variants:setVehicleVariants(targetVehicle, variant1, variant2)
        outputDebugString("Skopiowano warianty: " .. variant1 .. ", " .. variant2)
        return true
    end
    
    return false
end

-- ========================================
-- PRZYKŁAD 9: Integration z systemem parkingu
-- ========================================

-- Zapisz pojazd w garażu wraz z wariantami
function example9_saveToGarage(player, vehicle)
    local variant1, variant2 = exports.vehicle_variants:getVehicleVariants(vehicle)
    local vehicleModel = getElementModel(vehicle)
    
    -- Zapisz do bazy danych (przykład)
    local accountName = getAccountName(getPlayerAccount(player))
    -- executeSQLQuery("INSERT INTO garage VALUES (?, ?, ?, ?)", accountName, vehicleModel, variant1, variant2)
    
    setElementData(vehicle, "saved_variant1", variant1)
    setElementData(vehicle, "saved_variant2", variant2)
    
    outputChatBox("✅ Pojazd zapisany w garażu z wariantami!", player, 0, 255, 0)
end

-- Wczytaj pojazd z garażu
function example9_loadFromGarage(player, vehicleModel, variant1, variant2)
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(vehicleModel, x + 2, y, z)
    
    exports.vehicle_variants:setVehicleVariants(vehicle, variant1, variant2)
    
    outputChatBox("✅ Pojazd wczytany z garażu!", player, 0, 255, 0)
    return vehicle
end

--[[
    WSKAZÓWKI:
    
    1. Zawsze sprawdzaj czy pojazd istnieje przed użyciem funkcji
    2. Pamiętaj że nie wszystkie pojazdy wspierają warianty
    3. Wartości variant1 i variant2 są w zakresie 0-255
    4. 255 = brak dodatków, 0 = wszystkie dodatki
    5. Możesz łączyć ten system z systemem tuningu, garażami, etc.
    
    DEBUGGING:
    
    -- Sprawdź aktualne warianty
    local v1, v2 = exports.vehicle_variants:getVehicleVariants(vehicle)
    outputDebugString("Warianty: " .. v1 .. ", " .. v2)
]]
