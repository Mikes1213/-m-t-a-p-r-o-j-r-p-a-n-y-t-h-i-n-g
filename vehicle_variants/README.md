# 🚗 Vehicle Variants - System wariantów pojazdów dla MTA:SA

**Autor:** P.M (Piorun)  
**Wersja:** 1.0.0  
**Typ:** Resource dla MTA:SA

## 📋 Opis

System zarządzania wariantami pojazdów (Vehicle Variants) dla Multi Theft Auto: San Andreas. Umożliwia dynamiczną zmianę części wizualnych pojazdów takich jak spoilery, maski, zderzaki, lampy i wiele innych.

## ✨ Funkcje

- ✅ Kompletny system zarządzania wariantami pojazdów
- 🎨 GUI (F6) do łatwej zmiany części pojazdów
- 🎲 Losowanie wariantów
- 🧹 Czyszczenie pojazdu (usunięcie wszystkich dodatków)
- 🏎️ Predefiniowane style (czysty, sportowy, tuning)
- 💾 Automatyczne zapisywanie wariantów przy respawn pojazdu
- 📊 Eksportowane funkcje dla innych zasobów

## 🔧 Instalacja

1. Skopiuj folder `vehicle_variants` do folderu `resources` twojego serwera MTA:SA
2. Dodaj następującą linię do pliku `mtaserver.conf`:
   ```xml
   <resource src="vehicle_variants" startup="1" protected="0" />
   ```
3. Uruchom ponownie serwer lub użyj komendy: `/refresh` i `/start vehicle_variants`

## 🎮 Komendy

### Dla graczy:

| Komenda | Opis | Przykład |
|---------|------|----------|
| `/variant` | Wyświetla aktualne warianty pojazdu | `/variant` |
| `/variant [v1] [v2]` | Ustawia warianty pojazdu | `/variant 0 255` |
| `/randomvariant` | Losuje warianty pojazdu | `/randomvariant` |
| `/cleanvariant` | Usuwa wszystkie dodatki (czysty pojazd) | `/cleanvariant` |
| `/sportvariant` | Ustawia wszystkie dodatki (sportowy) | `/sportvariant` |
| `/variantpart [id] [0/1]` | Włącza/wyłącza konkretną część | `/variantpart 0 1` |
| `/testvariant` | Tworzy testowy pojazd z wariantami | `/testvariant` |

### GUI:
- **F6** - Otwiera/zamyka panel zarządzania wariantami (musisz być w pojeździe)

## 🔨 Części pojazdu (Vehicle Parts)

### Variant 1 (0-15):
- **0** - Spoiler
- **1** - Maska (Hood)
- **2** - Dach (Roof)
- **3** - Progi boczne (Side Skirt)
- **4** - Lampy (Lamps)
- **5** - Nitro
- **6** - Wydech (Exhaust)
- **7** - Felgi (Wheels)
- **8** - Stereo
- **9** - Hydraulika (Hydraulics)
- **10** - Zderzak przedni (Front Bumper)
- **11** - Zderzak tylny (Rear Bumper)
- **12** - Wentylacja prawa (Vent Right)
- **13** - Wentylacja lewa (Vent Left)

### Variant 2 (16-31):
- **16** - Światło taxi (Taxi Light)
- **17** - Skrzydła rozdzielone (Split Wings)

## 💻 API - Eksportowane funkcje

### Server-side:

```lua
-- Ustawia warianty pojazdu
exports.vehicle_variants:setVehicleVariants(vehicle, variant1, variant2)

-- Pobiera warianty pojazdu
local variant1, variant2 = exports.vehicle_variants:getVehicleVariants(vehicle)

-- Losuje warianty pojazdu
exports.vehicle_variants:randomizeVehicleVariants(vehicle)
```

### Przykłady użycia:

```lua
-- Przykład 1: Stworzenie pojazdu z konkretnymi wariantami
local vehicle = createVehicle(562, x, y, z) -- Elegy
exports.vehicle_variants:setVehicleVariants(vehicle, 0, 0) -- Wszystkie dodatki

-- Przykład 2: Czysty pojazd bez dodatków
exports.vehicle_variants:setVehicleVariants(vehicle, 255, 255)

-- Przykład 3: Losowe warianty
exports.vehicle_variants:randomizeVehicleVariants(vehicle)

-- Przykład 4: Odczyt aktualnych wariantów
local v1, v2 = exports.vehicle_variants:getVehicleVariants(vehicle)
outputChatBox("Warianty: " .. v1 .. ", " .. v2)
```

## 📖 Jak działają warianty?

Warianty w MTA:SA są reprezentowane przez dwie liczby (0-255), gdzie każdy bit określa czy dana część jest włączona czy wyłączona:

- **255** = wszystkie bity wyłączone (czysty pojazd, brak dodatków)
- **0** = wszystkie bity włączone (wszystkie dodatki)
- Wartości pośrednie = wybrane części

### Przykłady wartości:
- `variant1 = 255, variant2 = 255` - Czysty pojazd
- `variant1 = 0, variant2 = 0` - Wszystkie dodatki
- `variant1 = 254, variant2 = 255` - Tylko spoiler (bit 0)
- `variant1 = 252, variant2 = 255` - Spoiler + Maska (bit 0 i 1)

## 🎯 Kompatybilność

- Działa z wszystkimi pojazdami które wspierają warianty w GTA:SA
- Głównie pojazdy typu "Lowrider" i sportowe (np. Elegy, Flash, Stratum, itp.)
- Niektóre pojazdy mogą nie mieć wszystkich części

## 📝 Uwagi

1. Nie wszystkie pojazdy w GTA:SA wspierają warianty
2. Części dostępne zależą od modelu pojazdu
3. Warianty są zapisywane przy respawn pojazdu
4. System automatycznie triggeruje eventy dla synchronizacji

## 🔗 Linki

- [MTA:SA Wiki - Vehicle Variants](https://wiki.multitheftauto.com/wiki/Vehicle_variants)
- [MTA:SA Wiki - setVehicleVariant](https://wiki.multitheftauto.com/wiki/SetVehicleVariant)
- [MTA:SA Wiki - getVehicleVariant](https://wiki.multitheftauto.com/wiki/GetVehicleVariant)

## 📄 Licencja

Ten zasób jest częścią projektu MTA:SA Roleplay by P.M (Piorun).

---

**Enjoy! 🚗💨**
