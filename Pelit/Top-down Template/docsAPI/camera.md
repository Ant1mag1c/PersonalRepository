# camera.lua API Documentation

2D camera system for Solar2D with parallax support, smooth tracking, dead-zones, bounds constraints, and screen shake.

## Key Concepts

- **Parallax layers:** Multiple display groups with different scroll speeds (delta values)
- **Dead-zone:** Padding area where target can move without triggering camera movement
- **Smoothing:** Exponential interpolation for smooth camera following
- **Leash (maxDistance):** Hard limit on how far camera can lag behind target
- **Bounds:** World-coordinate limits that constrain camera position

---

## Setup

```lua
local camera = require( "camera" )

-- Initialize with parallax layers
-- delta: 1.0 = moves with camera, <1 = slower (background), >1 = faster (foreground)
camera.init( {
    { group = backgroundGroup, delta = 0.5 },
    { group = worldGroup, delta = 1.0 },
    { group = foregroundGroup, delta = 1.2 }
} )

-- Optional: Set world bounds
camera.setBounds( {
    xMin = 0,
    yMin = 0,
    xMax = 4000,
    yMax = 2000
} )
```

---

## Target Tracking

### `camera.setTarget( targetObject [, params] )`

Configure the object the camera should follow.

**Parameters:**

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `xOffset` | number | `0` | Horizontal offset from screen center (positive = target left of center) |
| `yOffset` | number | `0` | Vertical offset from screen center (positive = target above center) |
| `paddingLeft` | number | `0` | Dead-zone padding on the left |
| `paddingRight` | number | `0` | Dead-zone padding on the right |
| `paddingUp` | number | `0` | Dead-zone padding above |
| `paddingDown` | number | `0` | Dead-zone padding below |
| `smoothing` | number | `0` | Smoothing factor (0 = instant, higher = smoother/slower) |
| `smoothingSettleTime` | number | `2` | Multiplier for smoothing settle duration |
| `maxDistance` | number | `25% screen height` | Maximum allowed lag distance from ideal position |

```lua
-- Basic setup: camera follows player
camera.setTarget( player )

-- Platformer-style: target offset down, horizontal dead-zone
camera.setTarget( player, {
    yOffset = -100,
    paddingLeft = 150,
    paddingRight = 150,
    smoothing = 0.5
} )

-- Top-down with large dead-zone
camera.setTarget( player, {
    paddingLeft = 200,
    paddingRight = 200,
    paddingUp = 150,
    paddingDown = 150,
    smoothing = 0.3,
    maxDistance = 400
} )
```

### `camera.start( [params] )`

Begin tracking the target. Snaps to ideal position immediately, then tracks with configured smoothing.

```lua
camera.start()

-- With completion callback
camera.start( {
    onComplete = function()
        print( "Camera tracking started" )
    end
} )
```

### `camera.stop()`

Stop tracking. Camera holds its current position.

```lua
camera.stop()
```

---

## Manual Movement

### `camera.move( params )`

Move camera to a specific position. **Ignored while tracking is active.** Use for cutscenes, transitions, or when player control is disabled.

**Parameters:**

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `x` | number | `0` | Target X position |
| `y` | number | `0` | Target Y position |
| `movement` | string | `"absolute"` | `"absolute"` or `"relative"` |
| `time` | number | `0` | Duration in milliseconds (0 = instant) |
| `easing` | function | `easing.linear` | Solar2D easing function |
| `onComplete` | function | `nil` | Callback when movement finishes |

```lua
-- Instant jump to position
camera.move( { x = 1000, y = 500 } )

-- Smooth pan to position
camera.move( {
    x = 2000,
    y = 800,
    time = 1500,
    easing = easing.inOutQuad,
    onComplete = function()
        print( "Camera arrived" )
    end
} )

-- Relative movement (pan 200px right)
camera.move( {
    x = 200,
    y = 0,
    movement = "relative",
    time = 500
} )
```

---

## Screen Shake

### `camera.shake( [params] )`

Trigger screen shake effect. Stops any existing shake first.

**Parameters:**

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `time` | number | `300` | Total shake duration in milliseconds |
| `magnitude` | number | `4` | Maximum offset in pixels |
| `shakeCount` | number | `16` | Number of position changes during shake |

```lua
-- Default shake
camera.shake()

-- Heavy impact
camera.shake( {
    time = 500,
    magnitude = 12,
    shakeCount = 24
} )

-- Quick jolt
camera.shake( {
    time = 100,
    magnitude = 6,
    shakeCount = 4
} )
```

### `camera.shakeStop()`

Immediately stop any active shake and reset offset.

```lua
camera.shakeStop()
```

---

## Bounds

### `camera.setBounds( boundsTable )`

Set world-coordinate limits for camera position. Camera will not move beyond these bounds.

```lua
camera.setBounds( {
    xMin = 0,
    yMin = 0,
    xMax = levelWidth,
    yMax = levelHeight
} )

-- Remove bounds
camera.setBounds( nil )
```

---

## Query Functions

### `camera.getPosition()`

Returns current camera state with viewport bounds in world coordinates.

```lua
local pos = camera.getPosition()
-- pos.x, pos.y: camera center position
-- pos.xMin, pos.xMax: left/right edges of visible area
-- pos.yMin, pos.yMax: top/bottom edges of visible area

-- Example: check if object is visible
local function isOnScreen( obj )
    local pos = camera.getPosition()
    return obj.x >= pos.xMin and obj.x <= pos.xMax
       and obj.y >= pos.yMin and obj.y <= pos.yMax
end
```

### `camera.isTracking()`

Returns `true` if camera is actively tracking a target.

```lua
if camera.isTracking() then
    print( "Camera following target" )
end
```

### `camera.isMoving()`

Returns `true` if camera is in the middle of a `camera.move()` animation.

```lua
if camera.isMoving() then
    -- Wait for movement to complete
end
```

---

## Use Cases

### Platformer with Look-Ahead

```lua
camera.init( {
    { group = backgroundGroup, delta = 0.3 },
    { group = worldGroup, delta = 1.0 }
} )

camera.setBounds( { xMin = 0, yMin = 0, xMax = 8000, yMax = 1200 } )

-- Offset target so player sees more of what's ahead
-- Update xOffset based on player facing direction
local function updateCameraOffset()
    local offset = player.facingRight and -150 or 150
    camera.setTarget( player, {
        xOffset = offset,
        yOffset = -80,
        paddingLeft = 100,
        paddingRight = 100,
        smoothing = 0.4
    } )
end

camera.start()
```

### Cutscene Sequence

```lua
-- Stop player tracking
camera.stop()

-- Pan to boss
camera.move( {
    x = boss.x,
    y = boss.y,
    time = 2000,
    easing = easing.inOutQuad,
    onComplete = function()
        -- Boss roar with shake
        camera.shake( { time = 800, magnitude = 10 } )

        timer.performWithDelay( 1500, function()
            -- Return to player
            camera.move( {
                x = player.x,
                y = player.y,
                time = 1500,
                easing = easing.inOutQuad,
                onComplete = function()
                    camera.start()
                end
            } )
        end )
    end
} )
```

### Top-Down with Zoom Areas

```lua
-- Normal gameplay
camera.setTarget( player, {
    paddingLeft = 100,
    paddingRight = 100,
    paddingUp = 80,
    paddingDown = 80,
    smoothing = 0.3
} )
camera.start()

-- When entering a tight area, reduce dead-zone
local function onEnterTightSpace()
    camera.setTarget( player, {
        paddingLeft = 30,
        paddingRight = 30,
        paddingUp = 30,
        paddingDown = 30,
        smoothing = 0.5
    } )
end
```

### Impact Feedback

```lua
local function onEnemyHit( damage )
    if damage >= 50 then
        camera.shake( { time = 300, magnitude = 8, shakeCount = 12 } )
    else
        camera.shake( { time = 150, magnitude = 3, shakeCount = 6 } )
    end
end

local function onPlayerDeath()
    camera.shake( { time = 600, magnitude = 15, shakeCount = 30 } )
end
```

---

## Technical Notes

- **Coordinate system:** Camera position is in world coordinates. Screen center maps to `(currentX, currentY)`.
- **Parallax math:** Each group's position is `centerX - (cameraX * delta)`. Delta < 1 moves slower (distant background), delta > 1 moves faster (close foreground).
- **Smoothing algorithm:** Uses exponential decay (`1 - e^(-kt)`) for frame-rate-independent smoothing.
- **Shake implementation:** Uses `timer.performWithDelay` chain, not enterFrame. Shake offset is applied on top of camera position.
- **Movement priority:** Tracking takes precedence over manual movement. Call `camera.stop()` before `camera.move()` during cutscenes.
