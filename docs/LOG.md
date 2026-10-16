# Noční log

Nejnovější záznam nahoře. Formát:

```
## YYYY-MM-DD — M<n> — ✅/🟡/🔴
- Co jsem udělal:
- Důkaz: <řádek z výstupu testu>
- Co nefunguje:
- Co dál:
- Potřebuju od tebe:
```

## 2026-10-16 (večer) — M8.3 (rozpracováno) — 🟡
- architect: výjimky v OCIO → nepovolovat, nastavit `OIIO_DISABLE_BUILTIN_OCIO_CONFIGS=1` z JS (ADR-0005). Ověřeno: 60_python + 70_browser prošly i s thumbnailem; GUI jede do `wm_draw_update`.
- Co jsem udělal: no-op `Shader` + `ShaderCompiler`, `GPU_BACKEND_WEBGPU` v `standard_defines`, `GPU_SUPPORT_LEVEL_SUPPORTED`, null-guard v `WM_system_gpu_context_*` (`__EMSCRIPTEN__`).
- Důkaz: GUI režim v Chrome teď projde `GPU_init()` a start Pythonu; padá až na `Cannot convert 318 to a BigInt` (wasm64 + proxy volání na main thread). `CI ALL PASS` (11 stage) — `-b` režim se nezměnil.
- Pak: BigInt chyba = SDL3 kurzory (opraveno v GHOST pod `__EMSCRIPTEN__`). GUI načte cube.blend a padá na OCIO výjimce při čtení PNG.
- Co nefunguje: GUI se ještě nevykreslí; M8 DoD (`80_webgpu_clear`) zatím není.
- Potřebuju od tebe: nic.

---

## 2026-10-16 (večer) — M8.2 — ✅
- Co jsem udělal: kostra `gpu/webgpu/` (`GPU_BACKEND_WEBGPU`, `WebGPUBackend` zděděný z dummy, no-op StorageBuf/UniformBuf). Celý Blender se kvůli změně enumu přeložil znovu (~15 min), všech 11 stage zelených.
- Objev: Blender v GUI režimu v Chrome dojde až k vytvoření SDL okna a pak padá na nullptr objektech (viz STATUS „M8.3 — kde jsme“). To je přesně to, co architect předpověděl.
- Důkaz: `CI ALL PASS` (11 stage).
- Potřebuju od tebe: nic.

---

## 2026-10-16 (večer) — M8.1 — ✅
- Co jsem udělal: standalone test `tests/webgpu/clear.cpp` (WebGPU přes emdawnwebgpu) ve wasm64 + pthread + OffscreenCanvas. Headless Chrome má WebGPU přes SwiftShader (softwarové GPU).
- Důkaz: `center pixel rgb(255,0,255) vs #FF00FF → COLOR OK` / `WEBGPU TOOLCHAIN OK`.
- Past: většina Chrome flagů dávala černý/bílý screenshot, i když GPU kreslilo správně (ověřeno čtením textury). Funguje kombinace v ADR-0004.
- architect: M8 plán → nejdřív standalone test (hotovo), pak kostra z `gpu/dummy/`; JSPI netřeba (ADR-0004).
- Potřebuju od tebe: nic.

---

## 2026-10-16 (večer) — M7 — ✅
- Co jsem udělal: `scripts/link_web.sh` přelinkuje stejné objekty pro prohlížeč (bez NODERAWFS, s MEMFS) → `out/web/`. Zdroje (fonty, scripts, Python stdlib bez testů) se zabalí `file_packager` do `blender.data` (68 MB, zatím nezmenšeno).
- `web/index.html` nahraje cube.blend + roundtrip.py do MEMFS, Blender v `-b` režimu přidá kostku a uloží, stránka vrátí bajty; Playwright (systémový Chrome 155, wasm64 funguje) je uloží a desktop Blender ověří.
- Důkaz: `VALID .blend: 2 objects` / `BROWSER ROUNDTRIP OK` (stage `70_browser`, 116 s).
- Co nefunguje / pozor: thumbnail při ukládání (OCIO výjimka) je obejitý jen v testu; 404 na favicon (neškodné).
- Potřebuju od tebe: nic.

---

## 2026-10-16 (večer) — M6 — ✅
- Co jsem udělal:
  - CPython 3.13.13 pro wasm64 (`scripts/build_python.sh`, stage `55_python`: `PY OK 3.13.13 True`).
  - Dřívější ruční úpravy Pythonu (trampoline pro wasm64) jsou teď jako `patches/deps/python-wasm64.diff` — dřív byly jen v cache!
  - Blender `WITH_PYTHON=ON`, link prošel (konflikt dvou expat symbolů vyřešen přes `pyexpatns.h`).
  - Stage `60_python`: web Blender otevře cube.blend, přidá kostku, uloží; desktop Blender ověří.
- Důkaz: `VALID .blend: 2 objects` / `PYTHON ROUNDTRIP OK`
- Objev: `.gitignore` měl `deps/`, což ignorovalo i `patches/deps/` → patch pro OIIO nebyl nikdy v gitu (build_deps by při cache MISS spadl). Opraveno na `/deps/`.
- Objev: ukládání s náhledem shodí web build (OCIO výjimka, výjimky vypnuté). Obejito v testu; viz STATUS.
- architect: CPython wasm64 plán → přímý emconfigure, statické moduly, bez ctypes/bz2/lzma, patch trampoline.
- Pozor: BLENDER_SYSTEM_RESOURCES = adresář s `datafiles/`, `scripts/`, `python/` (`scripts/web_resources.sh`).
- Potřebuju od tebe: nic.

---

## 2026-10-16 (večer) — M5 — ✅
- cache: deps HIT, build-wasm HIT (ale po resetu zdroje se přeložilo ~6200 souborů znovu)
- Stage `50_headless` znovu s plným rebuildem: `STAGE PASS: 50_headless (1271s)`.
- Důkaz: `HEADLESS OK: Blender 5.2.2 LTS, cube.blend loaded, exit 0`
- `save_patch.sh` nic nezměnil → patch odpovídá stromu.
- Pozor: plný rebuild trvá ~70 min; ninja v CI nutno pouštět přes `setsid nohup` (30min limit nástroje).
- Potřebuju od tebe: nic.

---

## 2026-10-16 — M5 — ✅
- cache: deps HIT, build-wasm HIT
- Druhý link `blender` doběhl (už byl hotový z minula, `ninja: no work to do`).
- `blender -b --version` v Node → `Blender 5.2.2 LTS`. `blender -b cube.blend` → načte a skončí s kódem 0.
- Pozor: bez `BLENDER_SYSTEM_DATAFILES=blender/release/datafiles` spadne na chybějících fontech (assert v `BLF_default`). Stage to nastavuje; v M7 budou fonty v MEMFS.
- Důkaz: `HEADLESS OK: Blender 5.2.2 LTS, cube.blend loaded, exit 0`
- Stage `50_headless` přidána do `ci-stages.txt`. M6 rozepsán na úkoly, kód nezačat.
- Potřebuju od tebe: nic.

---

## 2026-10-15 — M5 (rozpracováno) — 🟡
- Zeď: wasm32 nejde (`dna_verify.cc`: offsetof(Scene…) nesedí). → ADR-0003: **wasm64**. Všechny deps přeloženy znovu.
- Opravy Blenderu (vše v `patches/blender-web.patch`, guardy `__EMSCRIPTEN__`):
  - `FE_DIVBYZERO/FE_INVALID` = 0 (Emscripten nemá FPU flagy),
  - `statfs` → `statvfs`,
  - `initClearGL()` jen s `WITH_OPENGL_BACKEND`,
  - upstream chyba `UNUSED_VARS(C, …)` v `disk_file_hash_service.cc` při buildu bez Pythonu.
- Build-tooly (makesdna, datatoc…) běží v Node: shebang + `-sNODERAWFS=1` (v `platform_wasm.cmake`).
- Důkaz: `CONFIGURE OK`, `DEPS OK`, `TOOLCHAIN OK` (wasm32 i wasm64).
- Link `blender` poprvé: 3 chyby (málo initial memory, `malloc_stats` neexistuje v Emscripten, `BPY_string_compile_check` bez Pythonu).
  Všechny 3 opraveny v patchi, ale druhý link nestihl doběhnout (změna hlavičky = přeložit vše znovu).
- Poučení: nespouštět `ninja` v Bash s `&` bez `setsid nohup` — nástroj ho po 30 min zabije.
- Co dál: `ninja blender`, `--version` v Node, stage `50_headless` (zatím NENÍ v ci-stages.txt).
- Potřebuju od tebe: viz STATUS.md.

---

## 2026-10-15 — M4 — ✅
- Co jsem udělal: `scripts/build_deps.sh` přeloží 16 knihoven do `deps/wasm` (verze podle Blenderu), stage `40_deps`.
- Důkaz: `DEPS OK`, seznam v `out/deps.txt`.
- OpenImageIO potřeboval malý patch pro Emscripten (`patches/deps/openimageio-emscripten.diff`).
- JPEG a PNG bereme z vlastního buildu, ne z Emscripten portů (aby OIIO a Blender sdílely jednu kopii).
- Pozor: `deps/` se v CI musí přeložit od nuly (cca 20–30 min) — workflow necachuje `deps/`.
  Potřebuju od tebe: zvážit přidání cache pro `deps/` do workflow (já workflow nesmím měnit).
- Epoxy (OpenGL loader) neřeším, WebGPU ho nepotřebuje.

---

## 2026-10-15 — M3 — ✅
- Co jsem udělal: `platform_wasm.cmake` + `blender_wasm_options.cmake`, stage `30_configure`.
- Důkaz: `CONFIGURE OK` (164 voleb v `out/cmake-options.txt`).
- Důležité: Blender 5.2 používá **SDL3**, ne SDL2 (viz `docs/decisions/0002-wasm-configure.md`).
- OIIO/OCIO/OpenEXR jsou povinné → zatím placeholder targety, skutečné v M4.
- Jednou jsem smazal `build-wasm/` (jen pro ověření, že patch funguje od nuly; byl nový, ne cache).
- Co dál: M4.
- Potřebuju od tebe: nic.

---

## 2026-10-15 — M1+M2 — ✅
- Co jsem udělal: M1 a M2 hotové.
- Oprava: `10_toolchain.sh` používal `emcc` (nelinkuje C++ knihovnu) → změněno na `em++`.
- Důkaz: `HELLO FROM WASM, threads=OK`, `TOOLCHAIN OK`, `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`.
- Co dál: M3 (CMake konfigurace pro wasm).
- Potřebuju od tebe: nic.

---

## 2026-10-14 — M0 — ✅
- Co se stalo: zkušební běh agenta. Stage `00_sanity` prošla, workflow otevřel PR.
- Důkaz: `SANITY OK`, `CI ALL PASS`; PR #2.
- Opravy po testu: skripty spustitelné (Windows je zneplatnil), `.ccache/` v `.gitignore`,
  runner připnutý na `ubuntu-24.04`, agent pokračuje dalšími úkoly až do konce časového limitu.
- Co dál: M1 (toolchain).

---

## 2026-10-12 — setup — ✅
- Co jsem udělal: založena kostra repa (CLAUDE.md, milníky, skripty, workflowy).
- Důkaz: zatím nic neběželo — první test proběhne v první noci (M0).
- Co dál: první noční běh, M0.
- Potřebuju od tebe: projít `PRIPRAVA.md` a nastavit secret + Actions.
