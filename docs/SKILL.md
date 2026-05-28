---
name: fui-weather-os
description: >
  Complete project map for "Aragorn Guan Weather OS" — a futuristic UI (FUI)
  real-time global weather app with a 3D globe, city weather panels, and live API
  data. Use this skill whenever the user mentions weather-os, FUI weather, the globe
  app, opening or fixing weather-os.html, satellite texture, city labels, temperature
  display, or any task related to the project in C:\Users\arago\Documents\Claude\Projects\FUI\.
  Also trigger for new FUI app requests that should match the same design language.
---

# FUI Weather OS — Project Map

## Project Identity

- **Full name**: Aragorn Guan Weather OS // Global Atmospheric Monitor
- **File**: `C:\Users\arago\Documents\Claude\Projects\FUI\weather-os.html`
- **Folder**: `C:\Users\arago\Documents\Claude\Projects\FUI\`
- **Design language**: Futuristic / cyberpunk HUD. Dark background (#050a14), cyan (#00d4ff) / amber (#ff9d00) / green (#00ff88) accent palette. Orbitron + Share Tech Mono + Rajdhani fonts. Glowing borders, scanline overlays, live-data tickers.

---

## Architecture at a Glance

```
weather-os.html         — single-file app (~90 KB without texture embed)
world.jpg               — 4000x2000 equirectangular satellite texture (1.4 MB)
embed_texture.py        — one-time script: embeds world.jpg as base64 -> world-texture.js
world-texture.js        — (generated) base64 data URL for offline/file:// texture loading
fix-and-open.bat        — double-click to embed texture + open HTML
```

### HTML Structure (all inline in one file)
```
<head>
  <style>          — full CSS (FUI design system)
  <script>         — Three.js r152 CDN import
<body>
  #app             — root container
    #sidebar-left  — world cities list + condition split
    #globe-panel   — Three.js canvas + city label overlays
    #sidebar-right — city detail, satellite image, atmospheric data, alerts
    #ticker        — scrolling city weather ticker
  <script>         — all application JS (inline, ~1100 lines)
```

---

## JavaScript Architecture

### Key Globals
| Variable | Purpose |
|---|---|
| `CITIES[]` | Array of city objects `{name, country, lat, lon, flag}` |
| `weatherData{}` | Keyed by city name, stores live API response |
| `globeGroup` | THREE.Group containing earth + atmosphere + markers |
| `earthMat` | THREE.MeshPhongMaterial for globe surface |
| `markerMeshes[]` | Cone markers per city |
| `pulseRings[]` | Animated pulse rings per city |
| `selectedCity` | Index of currently selected city |

### Key Functions
| Function | Purpose |
|---|---|
| `fetchAllWeather(initial)` | Calls Open-Meteo API for all cities; on `initial=true` rebuilds markers + labels |
| `buildCityLabels()` | Creates DOM label divs (`.city-label`) with temp + city name |
| `updateGlobeMarkers()` | Populates temp text into label elements after weather fetch |
| `addCityMarker(i)` | Adds cone + pulse ring for city `i` to globe |
| `selectCity(i)` | Updates right panel with city detail, triggers satellite image |
| `buildNightTexture()` | Creates procedural city-lights canvas texture (2048x1024) — works everywhere |
| `applyTex(tex)` | Applies a THREE.Texture to `earthMat.map` |

### Weather API
- **Provider**: Open-Meteo (free, no key needed)
- **Endpoint**: `https://api.open-meteo.com/v1/forecast?latitude=...&longitude=...&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation,weather_code,apparent_temperature&wind_speed_unit=kmh`
- **Refresh**: every 10 minutes via `setInterval`

### Satellite City Images
- **Provider**: Bing Maps static API
- URL: `https://dev.virtualearth.net/REST/V1/Imagery/Map/Aerial/{lat},{lon}/12?mapSize=400,220&key=...`

---

## Globe / Three.js Details

- **Version**: Three.js r152 (CDN)
- **Geometry**: `THREE.SphereGeometry(R=1, 80, 80)` for globe, `R*1.09` for atmosphere
- **Globe rotation**: `globeGroup.rotation.y = Math.PI` (initial facing: Africa/Europe)
- **Animation**: OrbitControls + auto-rotate (paused on user interaction)
- **Atmosphere**: Custom ShaderMaterial with additive blending for glow

### Globe Texture — Current State

| Context | Texture shown | How |
|---|---|---|
| `http://localhost:7777` | Satellite (world.jpg) | CanvasTexture from Image+Canvas |
| `file://` (direct open) | Night city-lights | `getImageData` detects tainted canvas → `buildNightTexture()` fallback |
| `file://` after embed | Satellite (world.jpg) | Data URL from `world-texture.js`, no CORS issue |

**Why file:// CORS issues occur**: Chrome treats all `file://` origins as unique/opaque. Drawing a `file://` image to canvas taints it; WebGL then silently rejects it (no exception). The explicit `ctx.getImageData(0,0,1,1)` call in the try-block detects this and routes to the night texture fallback.

**Texture loading code** (lines ~1149-1167):
```javascript
(function(){
  var img=new Image();
  img.onload=function(){
    try{
      var c=document.createElement('canvas');
      c.width=img.width; c.height=img.height;
      var ctx=c.getContext('2d');
      ctx.drawImage(img,0,0);
      ctx.getImageData(0,0,1,1); // throws SecurityError if canvas tainted (file:// CORS)
      var tex=new THREE.CanvasTexture(c);
      tex.colorSpace=THREE.SRGBColorSpace;
      applyTex(tex);
    }catch(e){applyTex(buildNightTexture());}
  };
  img.onerror=function(){applyTex(buildNightTexture());};
  img.src='./world.jpg'; // OR window.WORLD_JPG_DATA_URL after embed
})();
```

---

## Getting Satellite Texture in file:// Mode

Run `fix-and-open.bat` (double-click) **or** from a real Windows terminal:
```
C:\Users\arago\AppData\Local\Python\pythoncore-3.14-64\python.exe embed_texture.py
```

`embed_texture.py` does:
1. Reads `world.jpg` → base64 data URL (~1.9 MB string)
2. Writes `world-texture.js`: `window.WORLD_JPG_DATA_URL='data:image/jpeg;base64,...';`
3. Patches `weather-os.html`: adds script tag in `<head>`, changes `img.src` to use the variable

After running: `world-texture.js` (~1.9 MB) + modified `weather-os.html` (~2 MB total) in FUI folder.

---

## Cities (~30 major world cities)

Tokyo, Shanghai, Beijing, Mumbai, Delhi, Dubai, Karachi, Manila, Bangkok,
Singapore, Jakarta, Seoul, Osaka, Taipei, Riyadh, Cairo, Lagos, Nairobi, Moscow,
Istanbul, London, Paris, Madrid, Rome, Frankfurt, Zurich, Sydney, Auckland,
Buenos Aires, New York, Mexico City, Toronto, Chicago.

Each entry: `{name:'Tokyo', country:'JP', lat:35.6762, lon:139.6503, flag:'🇯🇵'}`

---

## Local Development Server

Start from an **actual Windows terminal** (MCP subprocesses are sandboxed and cannot bind ports accessible to Chrome):
```
C:\Users\arago\AppData\Local\Python\pythoncore-3.14-64\python.exe -m http.server 7777 --directory "C:\Users\arago\Documents\Claude\Projects\FUI"
```
Open: `http://localhost:7777/weather-os.html`

---

## Environment & Tool Notes

- **Python**: `C:\Users\arago\AppData\Local\Python\pythoncore-3.14-64\python.exe`
- **Desktop Commander limitation**: Subprocesses started via MCP are sandboxed — they CANNOT write files to the host filesystem or bind ports accessible from Chrome. Use only `Desktop Commander write_file` (direct MCP tool call) or the Claude `Write`/`Edit` tools for file writes.
- **Chrome extension**: Claude in Chrome connected as Browser 1 (Windows, local). Use `javascript_tool` for JS execution, `computer` tool for screenshots/clicks.
- **File tools (Read/Write/Edit)**: Work directly on the mounted FUI folder via Windows paths.

---

## Design System Quick Reference

```css
--cyan:      #00d4ff   /* primary accent */
--cyan-dim:  rgba(0,212,255,0.2)
--amber:     #ff9d00   /* warnings / hot temps */
--green:     #00ff88   /* positive / cool */
--red:       #ff3355   /* alerts / extreme */
--bg-deep:   #050a14
--bg-panel:  rgba(5,20,40,0.95)
--font-mono: 'Share Tech Mono'
--font-hud:  'Orbitron'
--font-body: 'Rajdhani'
```

FUI UI patterns:
- Panels: `border: 1px solid var(--cyan-dim)`, subtle box-shadow glow
- Section headers: uppercase, letter-spacing, cyan left border accent
- Live data badges: blinking green dot + "LIVE" label
- All temperatures in °C

---

## Known Issues & Fix History

| Issue | Root Cause | Fix Applied |
|---|---|---|
| Dark globe in `file://` mode | Canvas CORS taint; WebGL rejects silently | Added `getImageData()` taint check → `buildNightTexture()` fallback |
| Satellite texture unavailable in `file://` | Chrome `file://` CORS prevents canvas read | Run `embed_texture.py` to embed base64 data URL via `world-texture.js` |
| Temperatures showed `--°C` on globe | `buildCityLabels()` ran AFTER `updateGlobeMarkers()` | Call `updateGlobeMarkers()` again AFTER `buildCityLabels()` in `.then()` |
| Duplicate city labels | Old DOM labels not removed on rebuild | Clear `markerMeshes`/`pulseRings` arrays before re-adding |
| `THREE.TextureLoader` blocked on `file://` | TextureLoader uses XHR internally | Replaced with `new Image()` + Canvas approach |

---

## How to Continue Work

1. **Inspect**: `Read` weather-os.html with `offset`/`limit` to find specific sections
2. **Edit**: Use `Edit` tool (always `Read` first to confirm exact strings)
3. **Test on server**: Start python http.server in a real terminal, open in Chrome
4. **Test file://** directly: should show night texture (or satellite after running embed)
5. **Browser verification**: Use `mcp__Claude_in_Chrome__javascript_tool` + `computer` screenshot
