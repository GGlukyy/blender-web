# ADR-0002: Lite konfigurace CMake pro wasm

- Datum: 2026-10-15
- Stav: přijato

## Problém
Blender 5.2 chce při `cmake` předpřipravené knihovny (`lib/linux_x64`) nebo systémové.
Pro wasm nic z toho neexistuje.

## Rozhodnutí
- Nový soubor `build_files/cmake/platform/platform_wasm.cmake` (v patchi), použije se když je `EMSCRIPTEN`.
  Jediná změna ve stávajícím souboru: 3 řádky v `CMakeLists.txt` (výběr platformy).
- Volby: `scripts/blender_wasm_options.cmake` (základ = `blender_lite.cmake`).
- Vypnuto (mimo scope): Cycles, EEVEE-související extra, OpenVDB, OpenSubdiv, TBB, OpenMP, FFmpeg, audio,
  Alembic, USD, MaterialX, Wayland/X11, OpenGL a Vulkan backend (WebGPU přijde v M8), Python (zapne M6),
  testy, jemalloc, draco, manifold, libmv, i18n, IO (PLY/STL/OBJ/FBX).
- Z Emscripten portů: zlib, libpng, libjpeg, freetype, **SDL3**.
- **Pozor:** CLAUDE.md říká SDL2, ale Blender 5.2 používá SDL3 (`find_package(SDL3)`),
  a Emscripten 6.0.12 má port `sdl3`. Používáme SDL3.
- Zjištění: OpenImageIO, OpenColorIO, OpenEXR, Zstd, Epoxy, fmt, Eigen jsou v 5.2 POVINNÉ.
  Pro M3 jsou to **prázdné placeholder targety** (jen aby configure prošel).
  Skutečné knihovny se přeloží v M4 do `build-wasm/wasm-deps` (`WASM_DEPS_PREFIX`).

## Důsledky
- Configure prošel, ale build by teď selhal na chybějících hlavičkách — to řeší M4.
- Epoxy (OpenGL loader) pro WebGPU nejspíš nebude potřeba; ověřit v M4/M8.
