# Vehicle Variants Script dla MTA:SA

Skrypt do zarządzania wariantami pojazdów, w tym custom modelami (DFF/TXD) używając EngineFreeModel.

## Instalacja

1. Skopiuj pliki do folderu zasobu w MTA:SA (np. `resources/vehicle_variants/`)
2. Umieść pliki DFF/TXD w folderze zasobu (np. `models/`)
3. Uruchom zasób: `/start vehicle_variants`

## Jak używać Custom Modeli jako Wariantów

### Metoda 1: Edycja pliku (Zalecane)

Edytuj `vehicle_variants.lua` i dodaj do tabeli `customModelVariants`:

```lua
customModelVariants = {
    [560] = {  -- Sultan
        [1] = {
            customID = 18000,
            dff = "models/sultan_nodach.dff",
            txd = "models/sultan_nodach.txd"
        }
    }
}
```

### Metoda 2: Komenda admina

Użyj komendy w grze:
```
/addcustomvariant 560 1 18000 models/sultan_nodach.dff models/sultan_nodach.txd
```

Gdzie:
- `560` - ID modelu pojazdu (Sultan)
- `1` - Numer wariantu
- `18000` - Custom ID modelu (użyj zakresu 18000-30000)
- `models/sultan_nodach.dff` - ścieżka do pliku DFF
- `models/sultan_nodach.txd` - ścieżka do pliku TXD (opcjonalne)

## Komendy

- `/setvariant [wariant1] [wariant2]` - Ustawia wariant pojazdu, w którym jesteś
- `/asetvariant [ID pojazdu] [wariant1] [wariant2]` - Admin: ustawia wariant dowolnego pojazdu
- `/getvariant [ID pojazdu]` - Admin: sprawdza aktualny wariant
- `/addcustomvariant [modelID] [variant1] [customID] [dff] [txd]` - Admin: dodaje custom wariant

## Przykład użycia

1. Masz normalnego Sultana (model 560)
2. Dodajesz custom model bez dachu jako wariant 1
3. W pojeździe używasz: `/setvariant 1 0`
4. Pojazd zmienia się na Sultan bez dachu
5. Aby wrócić: `/setvariant 0 0`

## Ważne informacje

- Custom ID powinny być w zakresie 18000-30000 (wolne ID modeli)
- Pliki DFF/TXD muszą być w folderze zasobu
- Wariant 0 zawsze przywraca oryginalny model
- Custom modele są ładowane automatycznie przy pierwszym użyciu
