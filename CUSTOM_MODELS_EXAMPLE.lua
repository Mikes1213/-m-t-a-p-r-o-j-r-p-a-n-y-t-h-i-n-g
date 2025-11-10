--[[
    PRZYKŁAD KONFIGURACJI CUSTOM MODELI
    
    Aby dodać custom modele jako warianty pojazdów, edytuj plik vehicle_variants.lua
    i dodaj wpisy do tabeli customModelVariants.
    
    Format:
    [modelID] = {
        [variant1] = {
            customID = number,  -- Custom ID modelu (np. 18000-30000)
            dff = "ścieżka/do/model.dff",
            txd = "ścieżka/do/model.txd"  -- opcjonalne
        }
    }
    
    PRZYKŁAD: Sultan (560) z custom modelem bez dachu
]]

-- Przykład konfiguracji (odkomentuj i dostosuj ścieżki):
--[[
customModelVariants = {
    [560] = {  -- Sultan
        [1] = {
            customID = 18000,
            dff = "models/sultan_nodach.dff",
            txd = "models/sultan_nodach.txd"
        },
        [2] = {
            customID = 18001,
            dff = "models/sultan_tuning.dff",
            txd = "models/sultan_tuning.txd"
        }
    },
    [411] = {  -- Infernus
        [1] = {
            customID = 18002,
            dff = "models/infernus_custom.dff",
            txd = "models/infernus_custom.txd"
        }
    }
}
]]

-- INSTRUKCJA:
-- 1. Umieść pliki DFF i TXD w folderze zasobu (np. models/)
-- 2. Dodaj wpisy do customModelVariants w vehicle_variants.lua
-- 3. Użyj /setvariant 1 0 w pojeździe, aby przełączyć na custom model
-- 4. Użyj /setvariant 0 0 aby przywrócić oryginalny model
--
-- ALTERNATYWNIE możesz użyć komendy admina:
-- /addcustomvariant [modelID] [variant1] [customID] [ścieżka/do/model.dff] [ścieżka/do/model.txd]
--
-- Przykład:
-- /addcustomvariant 560 1 18000 models/sultan_nodach.dff models/sultan_nodach.txd
