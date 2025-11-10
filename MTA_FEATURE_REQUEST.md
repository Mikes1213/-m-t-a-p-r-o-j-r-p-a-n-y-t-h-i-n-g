# Feature Request: Support Custom Model IDs for Vehicle Creation and Model Changing

## Problem Description

Currently in MTA:SA, there are limitations when working with custom vehicle models (DFF/TXD files loaded via `engineLoadDFF` and `engineLoadTXD`):

1. **`setElementModel` does not work with custom IDs for vehicles** - When trying to change a vehicle's model to a custom ID (e.g., 18000), `setElementModel` returns `false` and the vehicle model remains unchanged.

2. **`createVehicle` cannot use custom IDs** - Server-side `createVehicle` function only accepts original vehicle model IDs (400-611). Custom IDs loaded via `engineFreeModel` and `engineLoadDFF` cannot be used to create vehicles.

3. **`engineReplaceModel` affects all vehicles globally** - While custom models can be loaded and replaced using `engineReplaceModel`, this affects ALL vehicles of that model type across the entire server, making it impossible to have different custom models for different vehicles of the same base type.

## Use Case

Many server owners want to create vehicle variants (e.g., Sultan with roof, Sultan without roof) where:
- Each vehicle instance can have its own custom model
- Players can switch between variants dynamically
- Different vehicles of the same base type can have different custom models simultaneously

**Example scenario:**
- Player A has a Sultan (model 560) with custom model "sultan_nodach.dff" (custom ID 18000)
- Player B has another Sultan (model 560) with original model
- Both vehicles should coexist on the server with different appearances

## Proposed Solution

### 1. Enable `setElementModel` for Custom Vehicle IDs

Allow `setElementModel` to work with custom IDs that have been properly loaded via `engineLoadDFF`:

```lua
-- Load custom model
engineFreeModel(18000)
local dff = engineLoadDFF("models/sultan_nodach.dff", 18000)
engineReplaceModel(dff, 18000)

-- This should work:
local vehicle = getPedOccupiedVehicle(player)
setElementModel(vehicle, 18000) -- Currently returns false, should return true
```

### 2. Enable `createVehicle` with Custom IDs

Allow `createVehicle` to accept custom IDs that have been loaded on clients:

```lua
-- On client: Load custom model
engineFreeModel(18000)
local dff = engineLoadDFF("models/sultan_nodach.dff", 18000)
engineReplaceModel(dff, 18000)

-- On server: Create vehicle with custom ID (should work)
local vehicle = createVehicle(18000, x, y, z) -- Currently fails, should succeed
```

### 3. Per-Vehicle Model Replacement (Optional Enhancement)

Consider adding a new function that allows per-vehicle model replacement without affecting other vehicles:

```lua
-- Proposed new function
setVehicleCustomModel(vehicle, customModelID, dffPath, txdPath)
```

This would:
- Load the custom model only for that specific vehicle instance
- Not affect other vehicles of the same base type
- Allow dynamic switching between custom and original models

## Benefits

1. **Flexibility** - Server owners can create multiple variants of the same vehicle type
2. **Better Roleplay Experience** - Players can customize their vehicles without affecting others
3. **Resource Efficiency** - No need to create separate vehicle types for each variant
4. **Backward Compatibility** - Existing code using original model IDs continues to work

## Technical Considerations

- Custom models must be loaded on clients before `setElementModel` or `createVehicle` can use them
- Server should validate that custom ID models are properly loaded before allowing their use
- Consider adding a function to check if a custom model ID is available: `isCustomModelLoaded(modelID)`
- Memory management: Ensure custom models are properly cleaned up when no longer needed

## Example Implementation

```lua
-- Client-side: Load custom model
function loadCustomVehicleModel(customID, dffPath, txdPath)
    engineFreeModel(customID)
    local txd = engineLoadTXD(txdPath, true)
    if txd then
        engineImportTXD(txd, customID)
    end
    local dff = engineLoadDFF(dffPath, customID)
    if dff then
        engineReplaceModel(dff, customID)
        return true
    end
    return false
end

-- Server-side: Create vehicle with custom model (after client loads it)
function createCustomVehicle(customID, x, y, z, rx, ry, rz)
    -- Wait for clients to load model, then:
    local vehicle = createVehicle(customID, x, y, z, rx, ry, rz)
    return vehicle -- Should work if custom ID is properly loaded
end

-- Server-side: Change vehicle model to custom ID
function setVehicleToCustomModel(vehicle, customID)
    local success = setElementModel(vehicle, customID)
    return success -- Should return true if custom ID is loaded
end
```

## Related Issues

This feature would complement existing custom model loading functions:
- `engineFreeModel`
- `engineLoadDFF`
- `engineLoadTXD`
- `engineImportTXD`
- `engineReplaceModel`

## Additional Notes

- This feature request is based on real-world usage scenarios from MTA:SA roleplay servers
- The limitation prevents many creative vehicle customization systems
- Similar functionality exists for objects (`createObject` with custom IDs works), so extending it to vehicles seems feasible

---

**Priority:** Medium-High (would significantly improve vehicle customization capabilities)

**Complexity:** Medium (requires changes to vehicle model handling system)

**Community Impact:** High (many servers would benefit from this feature)
