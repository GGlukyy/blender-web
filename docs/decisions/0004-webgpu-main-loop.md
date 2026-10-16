# ADR-0004: WebGPU ve wasm64 + vlákně — bez JSPI, přes callbacky a `emscripten_set_main_loop`

- Datum: 2026-10-16
- Stav: přijato — Schváleno: architect (Opus) 2026-10-16 (plán), ověřeno testem `75_webgpu_toolchain`

## Problém
WebGPU je asynchronní (`requestAdapter`, `requestDevice`). Blender běží v pthreadu (`-sPROXY_TO_PTHREAD`)
a v desktopu končí v nekonečné smyčce `WM_main()`. Potřebujeme device + vykreslení do canvasu.

## Možnosti
1. JSPI / `WaitAny` (synchronní čekání na device) + `emscripten_sleep(0)` v `WM_main`.
2. Callbacky (`AllowSpontaneous`) + `emscripten_set_main_loop` (jedna iterace smyčky na snímek).

## Rozhodnutí
Test `tests/webgpu/clear.cpp` ukázal, že **možnost 2 funguje** i v nejtěžší konfiguraci:
wasm64 + `-pthread -sPROXY_TO_PTHREAD` + `-sOFFSCREENCANVAS_SUPPORT=1 -sOFFSCREENCANVASES_TO_PTHREAD=#canvas`
+ `--use-port=emdawnwebgpu`. Canvas se vyčistí na `#FF00FF` (screenshot: `COLOR OK`).
JSPI nepotřebujeme. Pro Blender: init GPU backendu v callbacku, `WM_main` iterace v `emscripten_set_main_loop`.

## Důsledky
- Headless Chrome v CI potřebuje flagy: `--enable-unsafe-webgpu --enable-unsafe-swiftshader --ignore-gpu-blocklist --enable-gpu --use-angle=gl-egl --use-vulkan=swiftshader --enable-features=Vulkan`
  (jiné kombinace dávaly černý/bílý screenshot, i když GPU kreslilo správně).
- `creator.cc`/`wm.cc` pro `__EMSCRIPTEN__` budou potřebovat přepsání smyčky (další noc, M8.3).
