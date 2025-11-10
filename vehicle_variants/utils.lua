-- utils.lua - Funkcje pomocnicze dla systemu wariantów pojazdów
-- Autor: P.M (Piorun)

VehicleVariants = {}

-- Definicje części pojazdów (zgodnie z wiki MTA:SA)
VehicleVariants.PARTS = {
    -- Vehicle Variants 1 (0-15)
    SPOILER = 0,
    HOOD = 1,
    ROOF = 2,
    SIDE_SKIRT = 3,
    LAMPS = 4,
    NITRO = 5,
    EXHAUST = 6,
    WHEELS = 7,
    STEREO = 8,
    HYDRAULICS = 9,
    FRONT_BUMPER = 10,
    REAR_BUMPER = 11,
    VENT_RIGHT = 12,
    VENT_LEFT = 13,
    -- Vehicle Variants 2 (16-31) - opcjonalne części
    TAXI_LIGHT = 16,
    SPLIT_WINGS = 17,
}

-- Predefiniowane style wariantów
VehicleVariants.STYLES = {
    -- Czysty pojazd (bez dodatków)
    CLEAN = {
        variant1 = 255,
        variant2 = 255
    },
    -- Losowy styl
    RANDOM = function()
        return {
            variant1 = math.random(0, 255),
            variant2 = math.random(0, 255)
        }
    end,
    -- Sportowy (z dodatkami)
    SPORT = {
        variant1 = 0,  -- Wszystkie dodatki z variant1
        variant2 = 0   -- Wszystkie dodatki z variant2
    },
    -- Tuning - tylko wybrane części
    TUNED = {
        variant1 = 15, -- Spoiler, Hood, Roof, Side Skirt
        variant2 = 255
    }
}

-- Funkcja do konwersji bitów na wartość variant
function VehicleVariants.setBit(value, bit, state)
    if state then
        return value - (2^bit)
    else
        return value + (2^bit)
    end
end

-- Funkcja do sprawdzenia czy dany bit jest ustawiony
function VehicleVariants.getBit(value, bit)
    local bitValue = 2^bit
    return (value % (bitValue * 2)) < bitValue
end

-- Funkcja do wyświetlania aktualnych wariantów
function VehicleVariants.getVariantDescription(variant1, variant2)
    local description = {}
    
    -- Sprawdź variant1 (0-15)
    for i = 0, 15 do
        if not VehicleVariants.getBit(variant1, i) then
            local partName = "Unknown Part " .. i
            for name, index in pairs(VehicleVariants.PARTS) do
                if index == i then
                    partName = name
                    break
                end
            end
            table.insert(description, partName)
        end
    end
    
    -- Sprawdź variant2 (16-31) jeśli jest używany
    if variant2 < 255 then
        for i = 0, 15 do
            if not VehicleVariants.getBit(variant2, i) then
                local partName = "Unknown Part " .. (i + 16)
                for name, index in pairs(VehicleVariants.PARTS) do
                    if index == (i + 16) then
                        partName = name
                        break
                    end
                end
                table.insert(description, partName)
            end
        end
    end
    
    return description
end

return VehicleVariants
