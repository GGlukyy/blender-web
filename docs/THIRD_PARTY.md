# Cizí kód a nástroje

Každý cizí projekt, nástroj nebo zkopírovaný kus kódu sem musí být zapsaný.
Povolené licence: viz CLAUDE.md §6.

| Co | Odkud (URL + verze/commit) | Licence | Jak používáme | Soubory u nás |
|---|---|---|---|---|
| Blender | projects.blender.org/blender/blender @ `BLENDER_TAG` | GPL-2.0-or-later | port, upravujeme přes patch | `patches/blender-web.patch` |
| Emscripten SDK | github.com/emscripten-core/emsdk @ `EMSDK_VERSION` | MIT/UIUC | toolchain | — |
| Playwright | npm `playwright` | Apache-2.0 | screenshot testy | `tests/screenshot/` |
| pngjs, pixelmatch | npm | MIT / ISC | porovnání obrázků | `tests/screenshot/` |
