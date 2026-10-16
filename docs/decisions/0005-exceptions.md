# ADR-0005: C++ výjimky zůstávají vypnuté; OIIO heuristika barevných prostorů vypnutá přes ENV

- Datum: 2026-10-16
- Stav: přijato — Schváleno: architect (Opus) 2026-10-16, ověřeno (`60_python`, `70_browser` s thumbnailem, GUI probe)

## Problém
Emscripten build má výjimky vypnuté (`throw` = `Aborted(undefined)`). OpenImageIO při čtení/zápisu PNG
zavolá OpenColorIO, který *normálně* hodí výjimku „nenašel jsem ekvivalentní colorspace“ (OIIO ji na desktopu chytí).
Shodilo to ukládání s náhledem i start GUI.

## Možnosti
1. `-fwasm-exceptions` všude (deps + CPython + Blender): celý rebuild ~70+ min, riziko setjmp/longjmp.
2. Env `OIIO_DISABLE_BUILTIN_OCIO_CONFIGS=1` nastavená z JS před startem: žádný rebuild.

## Rozhodnutí
Možnost 2. Proměnná se nastavuje v `web/index.html`, `web/gui.html` a `scripts/web_resources.sh`
(OIIO ji čte jednou při startu wasm, `setenv` uvnitř Blenderu by bylo pozdě).
Workaround `file_preview_type='NONE'` z `tests/web/roundtrip.py` odstraněn.

## Důsledky
- OIIO pojmenovává barevné prostory jen jménem; Blender si převody dělá sám (odhad: dopad malý).
- Když se objeví další `throw` (OCIO/OpenEXR/yaml-cpp), přejít na možnost 1 jako samostatný „celý rebuild“ úkol.
