# Support Custom Model IDs for Vehicle Creation and Model Changing

## Problem

Currently in MTA:SA:
1. `setElementModel` returns `false` when trying to change vehicle model to custom ID (e.g., 18000)
2. `createVehicle` cannot use custom IDs - only accepts original vehicle IDs (400-611)
3. `engineReplaceModel` affects ALL vehicles globally, making per-vehicle customization impossible

## Use Case

Server owners want to create vehicle variants where each vehicle instance can have its own custom model:
- Player A: Sultan with custom model "sultan_nodach.dff" (custom ID 18000)
- Player B: Same Sultan with original model
- Both should coexist with different appearances

## Proposed Solution

1. **Enable `setElementModel` for custom vehicle IDs** - Allow changing vehicle model to custom IDs that have been loaded via `engineLoadDFF`

2. **Enable `createVehicle` with custom IDs** - Allow creating vehicles with custom model IDs after they're loaded on clients

3. **Optional: Per-vehicle model replacement** - New function `setVehicleCustomModel(vehicle, customID, dff, txd)` that affects only specific vehicle instance

## Example

```lua
-- Client: Load custom model
engineFreeModel(18000)
local dff = engineLoadDFF("models/sultan_nodach.dff", 18000)
engineReplaceModel(dff, 18000)

-- Server: Should work but currently doesn't
local vehicle = createVehicle(18000, x, y, z) -- Fails
setElementModel(existingVehicle, 18000) -- Returns false
```

## Benefits

- Multiple variants of same vehicle type
- Per-vehicle customization without affecting others
- Better roleplay experience
- Backward compatible with existing code

## Related Functions

- `engineFreeModel`
- `engineLoadDFF`
- `engineLoadTXD`
- `engineReplaceModel`

**Note:** Similar functionality works for objects (`createObject` with custom IDs), extending it to vehicles seems feasible.
