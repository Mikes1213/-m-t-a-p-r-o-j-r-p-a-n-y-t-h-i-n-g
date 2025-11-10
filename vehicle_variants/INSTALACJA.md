# 📦 Instrukcja instalacji - Vehicle Variants

## Krok 1: Skopiuj pliki

Skopiuj cały folder `vehicle_variants` do folderu `resources` w katalogu serwera MTA:SA.

Ścieżka powinna wyglądać tak:
```
mta-server/
└── mods/
    └── deathmatch/
        └── resources/
            └── vehicle_variants/
                ├── meta.xml
                ├── server.lua
                ├── client.lua
                ├── utils.lua
                ├── README.md
                ├── INSTALACJA.md
                └── example_usage.lua
```

## Krok 2: Dodaj resource do konfiguracji

Otwórz plik `mtaserver.conf` (znajduje się w głównym katalogu serwera) i dodaj linię:

```xml
<resource src="vehicle_variants" startup="1" protected="0" />
```

**Alternatywnie** możesz dodać resource ręcznie przez panel administracyjny lub konsolę serwera.

## Krok 3: Uruchom resource

### Opcja A - Restart serwera
1. Zatrzymaj serwer MTA:SA
2. Uruchom ponownie serwer
3. Resource zostanie automatycznie załadowany

### Opcja B - Bez restartu (przez konsolę)
1. Otwórz konsolę serwera lub wpisz w grze (jako admin):
```
/refresh
/start vehicle_variants
```

## Krok 4: Sprawdzenie działania

Po uruchomieniu resource:

1. **Dołącz do serwera**
2. **Wejdź do pojazdu** (np. `/car 562` jeśli masz taką komendę)
3. **Naciśnij F6** - powinieneś zobaczyć panel zarządzania wariantami
4. **Lub użyj komendy** `/variant` aby zobaczyć aktualne warianty

### Testowanie

```
/testvariant - Spawni testowego Elegy z wariantami
/randomvariant - Losuje warianty obecnego pojazdu
/cleanvariant - Czyści pojazd (usuwa wszystkie dodatki)
/sportvariant - Dodaje wszystkie dodatki
```

## Krok 5: Integracja z innymi zasobami (opcjonalne)

Jeśli chcesz używać tego systemu w innych swoich zasobach, dodaj do ich `meta.xml`:

```xml
<info type="script" />
```

A następnie w kodzie możesz używać exportowanych funkcji:

```lua
-- Przykład w innym resource
exports.vehicle_variants:setVehicleVariants(vehicle, 0, 0)
```

## Rozwiązywanie problemów

### Resource nie uruchamia się
- Sprawdź czy wszystkie pliki są w odpowiednim miejscu
- Sprawdź logi serwera w `server/mods/deathmatch/logs/`
- Upewnij się że plik `meta.xml` nie jest uszkodzony

### GUI nie otwiera się po F6
- Upewnij się że jesteś w pojeździe
- Sprawdź czy resource jest uruchomiony: `/refresh` i `/start vehicle_variants`
- Sprawdź czy F6 nie jest zbindowany do innej funkcji

### Warianty nie działają na niektórych pojazdach
- To normalne! Nie wszystkie pojazdy w GTA:SA wspierają warianty
- Warianty działają głównie na: Elegy (562), Flash (565), Stratum (561), i innych "tuningowalnych" pojazdach

### Potrzebujesz więcej pomocy?
- Sprawdź [MTA:SA Wiki](https://wiki.multitheftauto.com/)
- Zajrzyj do pliku `example_usage.lua` po więcej przykładów

## Konfiguracja uprawnień (ACL)

Jeśli chcesz ograniczyć dostęp do niektórych komend:

1. Otwórz `acl.xml` w folderze serwera
2. Dodaj uprawnienia dla grup (np. Admin, Moderator)

Przykład:
```xml
<group name="Admin">
    <acl name="Moderator"></acl>
    <acl name="Admin"></acl>
    <object name="resource.vehicle_variants"></object>
</group>
```

## Aktualizacja

Aby zaktualizować resource:
1. Zastąp stare pliki nowymi
2. Użyj `/refresh` w konsoli
3. Użyj `/restart vehicle_variants`

---

**Gotowe! Resource jest teraz zainstalowany i gotowy do użycia! 🎉**

Jeśli masz jakieś pytania, sprawdź plik `README.md` lub `example_usage.lua`.
