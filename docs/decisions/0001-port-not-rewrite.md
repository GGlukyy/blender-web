# ADR-0001: Portovat Blender, ne přepisovat

- Datum: 2026-10-12
- Stav: přijato

## Problém
Chceme Blender v prohlížeči pro malé assety. Šlo by ho buď přepsat (nová appka „jako Blender“),
nebo zkompilovat originální Blender do WebAssembly.

## Možnosti
1. Přepis (vlastní editor v Rust/TS + WebGPU).
2. Port originálního zdrojáku přes Emscripten + nový WebGPU backend.

## Rozhodnutí
**Port.** Hlavní hodnota projektu je, že web verze ukládá **nativní .blend**, který desktop
Blender otevře bez ztrát. To zaručí jen originální kód Blenderu. Přepis by .blend
spolehlivě nečetl ani nezapisoval. Port navíc znamená psát jen tenkou vrstvu
(build, GPU backend, platforma), ne miliony řádků.

## Důsledky
- Musíme napsat WebGPU backend a rozchodit Python ve wasm.
- Velikost wasm bude velká (desítky MB+).
- Držíme jednu verzi Blenderu (`BLENDER_TAG`), nehoníme nové.
