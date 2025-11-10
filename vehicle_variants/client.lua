-- client.lua - Client-side vehicle variants GUI and management
-- Autor: P.M (Piorun)

local variantGUI = {
    window = nil,
    gridlist = nil,
    button_enable = nil,
    button_disable = nil,
    button_random = nil,
    button_clean = nil,
    button_close = nil,
    label_current = nil,
    isVisible = false
}

-- Definicje części pojazdu z nazwami po polsku
local vehicleParts = {
    {index = 0, name = "Spoiler"},
    {index = 1, name = "Maska"},
    {index = 2, name = "Dach"},
    {index = 3, name = "Progi boczne"},
    {index = 4, name = "Lampy"},
    {index = 5, name = "Nitro"},
    {index = 6, name = "Wydech"},
    {index = 7, name = "Felgi"},
    {index = 8, name = "Stereo"},
    {index = 9, name = "Hydraulika"},
    {index = 10, name = "Zderzak przedni"},
    {index = 11, name = "Zderzak tylny"},
    {index = 12, name = "Wentylacja prawa"},
    {index = 13, name = "Wentylacja lewa"},
    {index = 16, name = "Światło taxi"},
    {index = 17, name = "Skrzydła rozdzielone"},
}

-- Funkcja sprawdzająca czy część jest aktywna
local function isPartEnabled(variant1, variant2, partIndex)
    if partIndex >= 0 and partIndex <= 15 then
        local bitValue = 2^partIndex
        return (variant1 % (bitValue * 2)) < bitValue
    elseif partIndex >= 16 and partIndex <= 31 then
        local bitIndex = partIndex - 16
        local bitValue = 2^bitIndex
        return (variant2 % (bitValue * 2)) < bitValue
    end
    return false
end

-- Funkcja aktualizująca listę części
local function updatePartsList()
    if not variantGUI.gridlist then return end
    
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end
    
    local variant1, variant2 = getVehicleVariant(vehicle)
    
    guiGridListClear(variantGUI.gridlist)
    
    for _, part in ipairs(vehicleParts) do
        local row = guiGridListAddRow(variantGUI.gridlist)
        guiGridListSetItemText(variantGUI.gridlist, row, 1, part.name, false, false)
        guiGridListSetItemText(variantGUI.gridlist, row, 2, tostring(part.index), false, false)
        
        local enabled = isPartEnabled(variant1, variant2, part.index)
        guiGridListSetItemText(variantGUI.gridlist, row, 3, enabled and "✅ TAK" or "❌ NIE", false, false)
        guiGridListSetItemData(variantGUI.gridlist, row, 1, part.index)
    end
    
    -- Aktualizuj label z aktualnymi wartościami
    if variantGUI.label_current then
        guiSetText(variantGUI.label_current, "Aktualne warianty: V1=" .. variant1 .. ", V2=" .. variant2)
    end
end

-- Funkcja tworząca GUI
local function createVariantGUI()
    if variantGUI.window then return end
    
    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = 500, 450
    local windowX = (screenW - windowW) / 2
    local windowY = (screenH - windowH) / 2
    
    variantGUI.window = guiCreateWindow(windowX, windowY, windowW, windowH, "🚗 Zarządzanie wariantami pojazdu", false)
    guiWindowSetSizable(variantGUI.window, false)
    
    -- Label z aktualnymi wartościami
    variantGUI.label_current = guiCreateLabel(10, 30, windowW - 20, 25, "Aktualne warianty: V1=255, V2=255", false, variantGUI.window)
    guiSetFont(variantGUI.label_current, "default-bold-small")
    guiLabelSetHorizontalAlign(variantGUI.label_current, "center")
    
    -- GridList z częściami
    variantGUI.gridlist = guiCreateGridList(10, 60, windowW - 20, 280, false, variantGUI.window)
    guiGridListAddColumn(variantGUI.gridlist, "Część pojazdu", 0.5)
    guiGridListAddColumn(variantGUI.gridlist, "ID", 0.15)
    guiGridListAddColumn(variantGUI.gridlist, "Status", 0.25)
    
    -- Przyciski akcji
    local buttonY = 350
    local buttonW = 110
    local buttonH = 30
    local spacing = 10
    local startX = 10
    
    variantGUI.button_enable = guiCreateButton(startX, buttonY, buttonW, buttonH, "✅ Włącz", false, variantGUI.window)
    variantGUI.button_disable = guiCreateButton(startX + buttonW + spacing, buttonY, buttonW, buttonH, "❌ Wyłącz", false, variantGUI.window)
    variantGUI.button_random = guiCreateButton(startX + (buttonW + spacing) * 2, buttonY, buttonW, buttonH, "🎲 Losuj", false, variantGUI.window)
    variantGUI.button_clean = guiCreateButton(startX + (buttonW + spacing) * 3, buttonY, buttonW, buttonH, "🧹 Wyczyść", false, variantGUI.window)
    
    -- Przycisk zamknięcia
    variantGUI.button_close = guiCreateButton(10, buttonY + buttonH + 10, windowW - 20, 30, "Zamknij", false, variantGUI.window)
    
    -- Dodaj handlery
    addEventHandler("onClientGUIClick", variantGUI.button_enable, function()
        local selectedRow = guiGridListGetSelectedItem(variantGUI.gridlist)
        if selectedRow ~= -1 then
            local partIndex = guiGridListGetItemData(variantGUI.gridlist, selectedRow, 1)
            triggerServerEvent("onClientRequestPartChange", localPlayer, partIndex, true)
        end
    end, false)
    
    addEventHandler("onClientGUIClick", variantGUI.button_disable, function()
        local selectedRow = guiGridListGetSelectedItem(variantGUI.gridlist)
        if selectedRow ~= -1 then
            local partIndex = guiGridListGetItemData(variantGUI.gridlist, selectedRow, 1)
            triggerServerEvent("onClientRequestPartChange", localPlayer, partIndex, false)
        end
    end, false)
    
    addEventHandler("onClientGUIClick", variantGUI.button_random, function()
        triggerServerEvent("onClientRequestRandomVariant", localPlayer)
    end, false)
    
    addEventHandler("onClientGUIClick", variantGUI.button_clean, function()
        triggerServerEvent("onClientRequestCleanVariant", localPlayer)
    end, false)
    
    addEventHandler("onClientGUIClick", variantGUI.button_close, function()
        toggleVariantGUI()
    end, false)
    
    updatePartsList()
end

-- Funkcja przełączająca widoczność GUI
function toggleVariantGUI()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        outputChatBox("❌ Musisz być w pojeździe!", 255, 0, 0)
        return
    end
    
    if not variantGUI.window then
        createVariantGUI()
    end
    
    variantGUI.isVisible = not variantGUI.isVisible
    guiSetVisible(variantGUI.window, variantGUI.isVisible)
    showCursor(variantGUI.isVisible)
    
    if variantGUI.isVisible then
        updatePartsList()
    end
end

-- Bind klawisza do otwierania GUI
bindKey("F6", "down", toggleVariantGUI)

-- Event handler dla zmian wariantów
addEvent("onVehicleVariantsChanged", true)
addEventHandler("onVehicleVariantsChanged", root, function(variant1, variant2)
    if variantGUI.isVisible then
        updatePartsList()
    end
end)

-- Server events
addEvent("onClientRequestPartChange", true)
addEvent("onClientRequestRandomVariant", true)
addEvent("onClientRequestCleanVariant", true)

outputDebugString("[Vehicle Variants] Client-side załadowany! Naciśnij F6 aby otworzyć GUI w pojeździe.")
outputChatBox("💡 System wariantów pojazdów załadowany! Naciśnij F6 w pojeździe aby otworzyć panel.", 100, 255, 100)
