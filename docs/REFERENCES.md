# Reference — kde hledat

## Uvnitř zdrojáku Blenderu (`./blender/`)
Cesty se mezi verzemi mohou mírně lišit — ověř si je `find`/`grep`.

| Co | Kde | K čemu |
|---|---|---|
| GPU vrstva (abstrakce) | `source/blender/gpu/` | rozhraní, které WebGPU backend implementuje |
| Vulkan backend | `source/blender/gpu/vulkan/` | **hlavní předloha** (moderní API, SPIR-V) |
| Metal backend | `source/blender/gpu/metal/` | druhá předloha, podobný model jako WebGPU |
| OpenGL backend | `source/blender/gpu/opengl/` | nejstarší, nejjednodušší pro pochopení |
| Výběr backendu | `grep -rn "GPU_BACKEND_" source/blender/gpu` | kde přidat `WEBGPU` |
| Shadery | `source/blender/gpu/shaders/`, `source/blender/draw/engines/workbench/`, `source/blender/draw/engines/overlay/` | co se musí přeložit |
| GHOST (okno, vstup) | `intern/ghost/` | `GHOST_SystemSDL.*` = SDL backend k reuse |
| Lite konfigurace | `build_files/cmake/config/blender_lite.cmake` | výchozí bod pro M3 |
| CMake volby | `CMakeLists.txt` (kořen) | seznam `WITH_*` voleb |
| Python verze | `build_files/build_environment/cmake/versions.cmake` | jakou verzi CPythonu potřebujeme |

## Externí projekty
| Projekt | K čemu | Licence |
|---|---|---|
| Emscripten — https://emscripten.org/docs/ | toolchain, pthreads, SDL2, WebGPU bindingy | MIT/UIUC |
| CPython `Tools/wasm` — https://github.com/python/cpython/tree/main/Tools/wasm | build Pythonu pro wasm32-emscripten | PSF |
| Pyodide — https://github.com/pyodide/pyodide | reference, jak řeší Python ve wasm | MPL-2.0 |
| Dawn / Tint — https://dawn.googlesource.com/dawn | SPIR-V → WGSL překlad, WebGPU hlavičky | BSD-3 |
| Naga — https://github.com/gfx-rs/wgpu/tree/trunk/naga | alternativní překladač shaderů | MIT/Apache-2.0 |
| Godot WebGPU (talk GodotCon Boston 2026) — https://talks.godotengine.org/godotcon-boston-2026/talk/CT739D/ | **stejný problém na jiném enginu**: backend proti abstrakci Vulkan/Metal, SPIR-V→WGSL, režie volání | ověřit |
| WebGPU spec — https://www.w3.org/TR/webgpu/ | co WebGPU umí a neumí (push constants, barriers…) | — |
| Blender devtalk — https://devtalk.blender.org/t/building-headless-blender-to-webassembly/18381 | dřívější pokus/diskuse | — |

## Známé rozdíly WebGPU vs Vulkan (na co si dát pozor)
- Žádné push constants → nahradit uniform bufferem.
- Žádné explicitní barriers ani subpasses — WebGPU synchronizuje samo.
- Přísnější pravidla pro bind groups a formáty textur.
- Každé volání GPU jde wasm → JS → GPU = režie. Dávkovat.
