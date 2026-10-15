# Cizí kód a nástroje

Každý cizí projekt, nástroj nebo zkopírovaný kus kódu sem musí být zapsaný.
Povolené licence: viz CLAUDE.md §6.

| Co | Odkud (URL + verze/commit) | Licence | Jak používáme | Soubory u nás |
|---|---|---|---|---|
| Blender | projects.blender.org/blender/blender @ `BLENDER_TAG` | GPL-2.0-or-later | port, upravujeme přes patch | `patches/blender-web.patch` |
| Emscripten SDK | github.com/emscripten-core/emsdk @ `EMSDK_VERSION` | MIT/UIUC | toolchain | — |
| Playwright | npm `playwright` | Apache-2.0 | screenshot testy | `tests/screenshot/` |
| pngjs, pixelmatch | npm | MIT / ISC | porovnání obrázků | `tests/screenshot/` |
| Emscripten ports: zlib, freetype, SDL3 | emsdk 6.0.12 (`--use-port=…`) | Zlib / FTL / Zlib | knihovny pro wasm build | `blender/…/platform_wasm.cmake` |
| zstd 1.5.7, fmt 12.1.0, Eigen, Imath 3.2.2, OpenEXR 3.4.10, libdeflate 1.18, OpenJPH 0.25.2, expat 2.7.5, yaml-cpp 0.8.0, pystring 1.1.3, minizip-ng 4.0.10, OpenColorIO 2.5.0, libjpeg-turbo 2.1.3, libpng 1.6.58, libtiff 4.7.1, OpenImageIO 3.1.13.1, robin-map 1.3.0 | stejné verze a URL jako `blender/build_files/build_environment/cmake/versions.cmake` | BSD-3 / MIT / BSD / Zlib / libpng / IJG+BSD / MPL-2.0 / Apache-2.0 (vše GPL-kompatibilní) | stahuje a překládá `scripts/build_deps.sh` do `deps/wasm` | `scripts/build_deps.sh`, `patches/deps/openimageio-emscripten.diff` |
