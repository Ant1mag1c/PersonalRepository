# Maps and PonyTiled API Documentation

Guide to the Tiled map system used in this template, including the PonyTiled map loader API, the extension system, and physics integration.

---

## Overview

Maps are created in [Tiled](https://www.mapeditor.org/), exported as JSON, and loaded at runtime by PonyTiled (`com/ponywolf/ponytiled.lua`). PonyTiled converts the map data into a Solar2D display group hierarchy:

```
map (display group)
  |-- layer 1 (display group)  -- e.g. "floor" tile layer
  |     |-- tile image 1
  |     |-- tile image 2
  |     |-- ...
  |-- layer 2 (display group)  -- e.g. "game" object layer
  |     |-- object 1
  |     |-- object 2
  |     |-- ...
  |-- ...
```

Each layer becomes a child display group of the map. Each tile or object becomes a display object within its layer group.

---

## Loading a Map

```lua
local ponytiled = require("com.ponywolf.ponytiled")
local json = require("json")

-- Load JSON data from the maps folder.
local mapData = json.decodeFile(
    system.pathForFile( "maps/house.json", system.ResourceDirectory )
)

-- Create the map display group.
-- The second argument is the base directory for tileset images.
local map = ponytiled.new( mapData, "maps" )
```

The `mapData` table contains raw Tiled data. You can read map dimensions from it:

```lua
local tileWidth = mapData.tilewidth     -- e.g. 16
local tileHeight = mapData.tileheight   -- e.g. 16
local mapPixelWidth = mapData.width * tileWidth
local mapPixelHeight = mapData.height * tileHeight
```

---

## Map API

After creating a map with `ponytiled.new()`, the returned map display group has these methods:

### Finding Objects

#### `map:findObject( name [, type] )`

Returns the first display object with the given name. Optionally filter by type.

```lua
local player = map:findObject( "hero" )
local door = map:findObject( "mainDoor", "door" )
```

Returns `false` if no match is found.

#### `map:findObjects( name1 [, name2, ...] )`

Returns a table of all display objects matching any of the given names.

```lua
local coins = map:findObjects( "coin" )
for i = 1, #coins do
    print( coins[i].x, coins[i].y )
end
```

#### `map:listTypes( type1 [, type2, ...] )`

Returns a table of all display objects matching any of the given types.

```lua
local enemies = map:listTypes( "enemy" )
local npcs = map:listTypes( "npc", "merchant" )
```

### Finding Layers

#### `map:findLayer( name )`

Returns the layer display group with the given name.

```lua
local physicsLayer = map:findLayer( "physics" )
if physicsLayer then
    physicsLayer.isVisible = false  -- hide collision shapes
end
```

Returns `false` if no match is found.

#### `map:searchLayers( pattern )`

Returns a table of layer display groups whose names contain the given pattern.

```lua
local bgLayers = map:searchLayers( "background" )
```

### Layer Visibility

#### `map:showLayer( name1 [, name2, ...] )`

Makes the named layers visible. Pass `"*"` to show all layers.

```lua
map:showLayer( "decorations" )
map:showLayer( "*" )  -- show everything
```

#### `map:hideLayer( name1 [, name2, ...] )`

Hides the named layers. Pass `"*"` to hide all layers.

```lua
map:hideLayer( "physics" )
```

#### `map:soloLayer( name1 [, name2, ...] )`

Hides all layers except the named ones. Saves previous visibility state.

```lua
map:soloLayer( "floor", "game" )
```

#### `map:defaultLayers()`

Restores layer visibility to the state before `soloLayer` was called.

```lua
map:defaultLayers()
```

### Tile Lookup

#### `map.getFirstTile( property [, value] )`

Returns the first tile display object that has the given property. Optionally filter by a specific value.

```lua
local spawnTile = map.getFirstTile( "isSpawn", true )
```

#### `map.getAllTiles( property [, value] )`

Returns a table of all tile display objects that have the given property.

```lua
local waterTiles = map.getAllTiles( "terrain", "water" )
```

### Sorting

#### `map:sort( [reverse] )`

Sorts all objects in every layer by position (top-to-bottom, left-to-right). Called automatically when the map is created.

#### `map:sortLayer( layerName [, reverse] )`

Sorts objects in a specific layer only.

```lua
map:sortLayer( "game" )
```

### Centering

#### `map:centerObject( name [, tween] )`

Moves the map so the named object is centered on screen. If `tween` is true, moves gradually (1/8th of the distance per call).

```lua
map:centerObject( "hero" )
map:centerObject( "hero", true )  -- gradual movement
```

#### `map:centerAnchor()`

Translates all objects so the map center aligns with position (0, 0).

### Bounds Checking

#### `map:boundsCheck( [border] )`

Prevents the map from scrolling past its edges. The optional `border` parameter adds padding.

### Animation Control

#### `map:pauseAnimations()`

Pauses all animated sprites in the map.

#### `map:playAnimation( layerName )`

Plays all animated sprites in layers matching the name pattern.

#### `map:restartAnimation( layerName )`

Restarts all animated sprites in matching layers from frame 1.

---

## Extension System

The extension system is how you turn static Tiled objects into interactive game entities. It connects object `type` values from Tiled to Lua modules.

### How it works

1. In Tiled, you set an object's **Type** property (e.g. `"hero"`, `"exit"`, `"npc"`).

2. In your game code, you tell PonyTiled where to find extension modules and which types to process:

   ```lua
   map.extensions = "maps.extensions."  -- module path prefix
   map:extend( "hero", "exit" )
   ```

3. For each type, PonyTiled:
   - Calls `require("maps.extensions.hero")` to load the module.
   - Finds all objects in the map with `type == "hero"`.
   - Calls `module.new(instance)` for each one, passing the display object.

4. The extension module receives the display object and can modify or replace it.

### Extension module structure

```lua
local M = {}

function M.new( instance )
    if not instance then error("ERROR: Expected display object") end

    -- 'instance' is a Solar2D display object created by PonyTiled.
    -- Available properties from Tiled:
    --   instance.name       -- the object's Name in Tiled
    --   instance.type       -- the object's Type in Tiled
    --   instance.id         -- Tiled's unique object ID
    --   instance.x, instance.y -- position on the map
    --   instance.width, instance.height -- object dimensions
    --   instance.rotation   -- rotation in degrees
    --   instance.isVisible  -- visibility flag
    --   instance.gid        -- tile GID (if placed as a tile object)
    --   + any custom properties set in Tiled

    -- Add behavior, physics, sprites, etc.
    -- ...

    -- Clean up when the object is removed.
    function instance:finalize()
        -- Remove listeners, timers, etc.
    end
    instance:addEventListener( "finalize" )

    return instance
end

return M
```

### Replacing vs. modifying

You can either modify the instance in place or replace it entirely. The hero extension replaces the original Tiled object with a new display group containing an animated sprite:

```lua
function M.new( instance )
    -- Save position and parent.
    local parent = instance.parent
    local x, y = instance.x, instance.y

    -- Remove the PonyTiled-created display object.
    display.remove( instance )

    -- Create a new display group as the replacement.
    instance = display.newGroup()
    -- ... add sprites, physics, etc. ...
    parent:insert( instance )
    instance.x, instance.y = x, y

    return instance
end
```

### Built-in extensions

The template includes these extensions in `maps/extensions/`:

#### hero.lua

Creates the player character from a Tiled tile object.

- Replaces the static tile with an animated sprite (16x16, 10 frames).
- Adds a dynamic physics body (circle, radius 6).
- Provides `instance:move(vx, vy)` and `instance:stop()` methods.
- Automatically switches between idle/walk animations based on velocity and direction.
- Animation data is loaded from `maps/extensions/animations.lua`.

**Tiled setup:** Place a tile object with `name = "hero"`, `type = "hero"`.

#### exit.lua

Creates a map transition zone.

- Listens for collision with the hero.
- On contact, stops controls and transitions to `scenes/refresh.lua` with the target map name.
- The exit's `name` property determines the target map.

**Tiled setup:** Draw a rectangle with `name = <target map>`, `type = "exit"`. Add custom properties: `bodyType = "static"`, `isSensor = true`.

#### animations.lua

Not an extension module -- it's a data file that returns animation sequence definitions for the hero sprite sheet:

```lua
return { hero = {
    { name = "idleSouth", frames = { 1 }, time = 666, loopCount = 0 },
    { name = "walkSouth", frames = { 1, 4, 1, 9 }, time = 666, loopCount = 0 },
    -- ... 8 total sequences (idle + walk for each direction)
}}
```

#### world.lua

Helper utilities for world/camera container groups. Provides `center()`, `reset()`, and `centerObj()` methods.

---

## Physics Properties Reference

When a Tiled object has a `bodyType` custom property, PonyTiled automatically creates a Solar2D physics body for it. These are all the physics-related properties that PonyTiled recognizes:

| Property | Type | Description |
|----------|------|-------------|
| `bodyType` | string | **Required.** `"static"`, `"dynamic"`, or `"kinematic"` |
| `density` | number | Mass density (default varies by Solar2D) |
| `friction` | number | Surface friction, 0 to 1 |
| `bounce` | number | Restitution / bounciness, 0 to 1 |
| `radius` | number | Circular collision shape radius in pixels |
| `isSensor` | boolean | Detects collisions but doesn't cause physical response |
| `isBox` | boolean | Use a box shape with custom dimensions |
| `boxWidth` | number | Box half-width multiplier (default 0.5 = half object width) |
| `boxHeight` | number | Box half-height multiplier (default 0.5 = half object height) |
| `boxX` | number | Box shape X offset from center |
| `boxY` | number | Box shape Y offset from center |
| `boxAngle` | number | Box shape rotation angle |
| `autoShape` | number | Auto-trace tolerance for generating an outline shape from the image |
| `outline` | table | Explicit outline shape (set via `autoShape` or manually) |

### How different object shapes map to physics bodies

| Tiled Object | Physics Shape |
|--------------|---------------|
| Rectangle | Box body (from object dimensions) |
| Ellipse / Circle | Circle body (average of width and height as diameter) |
| Polygon | Chain body (vertices from the polygon points, closed loop) |
| Polyline | Chain body (vertices from the polyline points, open) |
| Tile object with `isBox` | Custom-sized box body |
| Tile object with `radius` | Circle body |
| Tile object with `autoShape` | Outline body traced from the image |

### Physics on tile layers

Individual tiles in tile layers can also have physics bodies. To set this up:

1. In Tiled, open the tileset editor (double-click the tileset).
2. Select a tile and add custom properties (e.g. `bodyType = "static"`, `friction = 0.5`).
3. Every instance of that tile in any tile layer will get a physics body with those properties.

This is useful for creating collision on wall tiles or other environmental elements without manually placing object shapes.

### Additional physics properties on display objects

These properties are not handled by PonyTiled but can be set in an extension's `M.new()` function after adding a physics body:

```lua
physics.addBody( instance, "dynamic", { radius = 6 } )
instance.isFixedRotation = true  -- prevent tumbling
instance.linearDamping = 15      -- friction-like slowdown
instance.angularDamping = 5      -- rotational slowdown
```

---

## Tiled Export Settings

When saving maps from Tiled for use with this template:

- **Format:** JSON map files (`.json`)
- **Tile layer format:** CSV (do not use Base64 or compressed encoding -- PonyTiled doesn't support them)
- **Tilesets:** Should be embedded in the map file. External tileset references (`.tsx`) are only partially supported.
- **Tile render order:** Right Down (default)
- **File location:** Save directly into the `maps/` folder

---

## Tips and Troubleshooting

### Object type not triggering extension

- Check that the **Type** field in Tiled (not the Name field) matches the extension filename exactly (case-sensitive).
- Make sure you've added the type to the `map:extend()` call in `scenes/game.lua`.
- Verify the extension file exists at `maps/extensions/<type>.lua`.

### Physics bodies not working

- Objects need a `bodyType` custom property to get a physics body. Without it, PonyTiled skips physics entirely for that object.
- Custom properties in Tiled are case-sensitive. Use `bodyType`, not `bodytype` or `BodyType`.
- For sensor objects (like exits), set both `bodyType = "static"` and `isSensor = true`.

### Map appears offset or misaligned

- Make sure your tile size in the Tiled map matches the tileset's tile size (16x16 for the included tileset).
- PonyTiled positions tiles with anchor at center. If you see half-tile offsets, check that the tileset margin and spacing match between Tiled and the image.

### Tile layer encoding error

If you see `"ERROR: Tile layer encoding/compression not supported"`, your map is using Base64 or compressed tile data. In Tiled, go to **Map > Map Properties** and set the tile layer format to CSV.

### Performance with large maps

- Large tile layers (100x100+) create many display objects. Consider splitting large maps into smaller connected maps using exit zones.
- Hide layers that don't need to be visible (like physics layers) to reduce rendering overhead.

### External tilesets

PonyTiled has limited support for external tileset references (`.tsx` files). It can load them but only for sprite sheet-based tilesets. For reliable results, embed your tilesets in the map file: in Tiled, right-click the tileset and choose **Embed Tileset**.
