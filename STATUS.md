# STATUS

Výsledek noci: ✅ pokrok — M5, M6, M7 DONE (`BROWSER ROUNDTRIP OK`); M8.1 + M8.2 hotové (WebGPU clear v prohlížeči funguje samostatně, kostra backendu v Blenderu se přeložila); 11 stage zelených

## Aktuální milník
**CURRENT: M8 — WebGPU backend, kostra (vyčistit plátno na #FF00FF)**

## Úkoly aktuálního milníku
- [x] M5.6 **Opravit `scripts/stages/50_headless.sh`, aby prošla i v CI** (`scripts/ci.sh 50_headless`).
      V běhu 2026-10-16 agentovi prošla (build z cache, `ninja: no work to do`), ale v závěrečném
      CI spadla po 92 s. Ověř po `scripts/prepare_blender.sh --reset` + `ninja blender`.
      Až projde → přidej do `ci-stages.txt`, M5 DONE, pak M6.
- [x] M6.1–M6.5 hotovo (viz Hotové milníky)
- [x] M8.1 architect + ADR-0004 + de-risk: wasm64+pthread+OffscreenCanvas+WebGPU vyčistí canvas na #FF00FF (`75_webgpu_toolchain`: `WEBGPU TOOLCHAIN OK`)
- [x] M8.2 (kostra `gpu/webgpu/wgpu_backend.hh` + `GPU_BACKEND_WEBGPU`, celý Blender se přeložil, všech 11 stage zelených) Prázdný `source/blender/gpu/webgpu/` (CMake `WITH_GPU_WEBGPU_BACKEND`), který se přeloží; přečíst vulkan/ + metal/ šablony
- [ ] M8.3 `WebGPUBackend`: adapter + device + swapchain na canvas, clear barvou
- [ ] M8.4 Stage `80_webgpu_clear.sh` (Playwright screenshot plátna = #FF00FF ±2)

## Zaseknuto (BLOCKED)
- nic

## M8.3 — kde jsme (GUI režim v prohlížeči)
- `web/gui.html` + `tests/web/gui_probe.mjs`: Blender bez `-b` v Chrome (po `scripts/link_web.sh`; zkopíruj `web/gui.html` do `out/web/`).
- Hotovo: SDL okno, `GPU_init()` projde (no-op StorageBuf/UniformBuf/Shader + `ShaderCompiler` v `gpu/webgpu/`), Python UI startuje.
- Opraveno: `Cannot convert 318 to a BigInt` = SDL3 port (vlastní kurzor, EM_ASM není wasm64-safe) → v GHOST `__EMSCRIPTEN__` kurzory vypnuté (prohlížečový výchozí kurzor).
- OCIO výjimka vyřešena bez rebuildu: `OIIO_DISABLE_BUILTIN_OCIO_CONFIGS=1` z JS (ADR-0005). Thumbnail při ukládání už funguje (workaround z testu odstraněn).
- GUI teď běží až do `wm_draw_update` (kreslí splash/menu) a padá na `gpu_texture_create` (nullptr `Texture`) — další no-op objekt.
- Pak čekají: Texture, IndexBuf, Fence, QueryPool, PixelBuffer, TexturePool (nullptr v dummy), skutečný WebGPU device (M8.3), canvas clear (M8.4).
- Debug tip: relink s `--profiling-funcs` (viz LESSONS.md), stack v Chrome pak má jména funkcí.

## Známé problémy (pro příště)
- ~~Ukládání s náhledem (OCIO výjimka)~~ vyřešeno, ADR-0005.
- Chybí Python modul `_multiprocessing` a `_opcode` (addon `bl_pkg` se nenačte, jen chybová hláška).

## Co dál
- M8.3: no-op `Texture` (+ IndexBuf, Fence, QueryPool, PixelBuffer, TexturePool, FrameBuffer ověřit), doplnit, pak skutečný device + clear z `tests/webgpu/clear.cpp` přenést do `gpu/webgpu/`.
- Později zmenšit `blender.data` (68 MB) — M11/M13.

## Potřebuju od tebe (Lukáši)
- nic (2026-10-15: ADR-0003 wasm64 **schváleno**; cache pro `deps/` a `build-wasm/` workflow už má — viz LESSONS.md)

## Hotové milníky
- M7 — Prohlížeč (2026-10-16): `BROWSER ROUNDTRIP OK` (Chrome 155, `scripts/link_web.sh` = relink bez rekompilace, data v MEMFS)
- M6 — Python (2026-10-16): `PYTHON ROUNDTRIP OK` (`VALID .blend: 2 objects`), CPython 3.13.13 wasm64
- M5 — Headless (2026-10-16): `HEADLESS OK: Blender 5.2.2 LTS, cube.blend loaded, exit 0` (po plném rebuildu)
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M4 — Závislosti (2026-10-15): `DEPS OK` (16 knihoven, `out/deps.txt`)
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
