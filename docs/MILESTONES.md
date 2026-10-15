# Milníky (MILESTONES)

Každý milník má **Definition of Done (DoD)** = konkrétní test, který musí projít.
Milník je hotový **jen** když DoD projde v CI. Odhady jsou hrubé (nocí = nočních běhů).

Legenda: 🧱 infrastruktura · ⚙️ build · 🎨 grafika · 🖱️ UI/vstup

---

## M0 🧱 Kostra repa a CI (≈1 noc)
**Cíl:** repo, skripty a noční workflow fungují, i když se ještě nic nebuilduje.
- [ ] `scripts/ci.sh` projde se stage `00_sanity`.
- [ ] Noční workflow doběhne a otevře PR (i prázdný).
**DoD:** `scripts/stages/00_sanity.sh` → `SANITY OK`, PR z nočního běhu existuje.

## M1 ⚙️ Toolchain (≈1 noc)
**Cíl:** Emscripten v pinned verzi umí přeložit C++ do wasm a spustit to.
**DoD:** `scripts/stages/10_toolchain.sh` → přeloží `tests/toolchain/hello.cpp` (s vlákny)
a v Node vypíše `HELLO FROM WASM, threads=OK`.

## M2 ⚙️ Zdroják Blenderu + reference (≈1–2 noci)
**Cíl:** Blender v pinned verzi se stáhne, patch se aplikuje; desktop Blender vyrobí
testovací scény a referenční obrázky.
**DoD:** `20_blender_source.sh` → `BLENDER SOURCE OK <tag>`;
`25_references.sh` → existuje `out/reference/cube_solid.png` a `out/scenes/cube.blend`.

## M3 ⚙️ Konfigurace CMake pro wasm (≈2–4 noci)
**Cíl:** `emcmake cmake` s lite konfigurací doběhne bez chyby.
- Vypnout vše mimo scope (Cycles, EEVEE Next, OpenVDB, OIDN, FFmpeg, Alembic, USD, …).
- Zapisovat do `docs/decisions/` co a proč je vypnuté.
**DoD:** `30_configure.sh` → `CONFIGURE OK` + soubor `out/cmake-options.txt`.

## M4 ⚙️ Závislosti pro wasm (≈3–6 nocí)
**Cíl:** všechny knihovny, které lite build potřebuje, jsou přeložené pro wasm a cachované
(zlib, libpng, libjpeg, freetype, …; Emscripten porty kde to jde).
**DoD:** `40_deps.sh` → `DEPS OK` a seznam knihoven s verzemi v `out/deps.txt`.

## M5 ⚙️ Headless Blender ve wasm, BEZ Pythonu (≈4–8 nocí) ⭐ první velký milník
**Cíl:** Blender jádro se slinkuje do `blender.wasm` (`WITH_PYTHON=OFF`, bez GPU)
a v Node se spustí v background režimu.
**DoD:** `50_headless.sh` → v Node: `blender -b --version` vypíše verzi
a `blender -b out/scenes/cube.blend` načte soubor a skončí s kódem 0.

## M6 ⚙️ Python ve wasm + roundtrip .blend (≈4–8 nocí) ⭐
**Cíl:** CPython pro wasm, Blender s `WITH_PYTHON=ON`. Python skript otevře .blend,
přidá objekt, uloží.
**DoD:** `60_python.sh` → web build uloží `out/roundtrip.blend`;
**desktop** Blender ho otevře a `tests/validate_blend.py` vypíše `VALID .blend: 2 objects`.

## M7 🧱 Běh v prohlížeči (≈2–4 noci)
**Cíl:** stejný roundtrip jako M6, ale v headless Chromu přes `web/index.html`
(COOP/COEP server, MEMFS, stažení .blend).
**DoD:** `70_browser.sh` (Playwright) → `BROWSER ROUNDTRIP OK`.

## M8 🎨 WebGPU backend — kostra (≈3–6 nocí)
**Cíl:** nový `source/blender/gpu/webgpu/`, Blender ho umí vybrat, inicializuje device
a vyčistí plátno na danou barvu. Okno přes GHOST SDL.
**DoD:** `80_webgpu_clear.sh` → screenshot plátna má barvu `#FF00FF` (±2).
**Pozor (main loop):** desktop Blender končí v nekonečné smyčce `WM_main()`. Díky
`-sPROXY_TO_PTHREAD` neblokuje hlavní vlákno prohlížeče, ale WebGPU v tom vlákně potřebuje
vracet řízení event loopu (jinak se snímek nikdy neprezentuje a async volání jako
`requestAdapter` nedoběhnou). Plán: pro `__EMSCRIPTEN__` nahradit smyčku
`emscripten_set_main_loop_arg()` (jedna iterace = events → handlers → notifiers →
`wm_draw_update`), případně ASYNCIFY/JSPI. Canvas do workeru přes OffscreenCanvas.
Rozhodnutí zapsat jako ADR, před návrhem se poradit s `architect`.

## M9 🎨 Shadery do WGSL (≈4–10 nocí)
**Cíl:** všechny shadery potřebné pro Workbench Solid + overlaye + UI se přeloží
GLSL → SPIR-V → WGSL (Tint) při buildu.
**DoD:** `90_shaders.sh` → `SHADERS OK: N/N` (seznam v `out/shaders-report.txt`,
žádný shader neselže).

## M10 🎨 První kostka v prohlížeči (≈5–10 nocí) ⭐⭐ hlavní milník
**Cíl:** `cube.blend` vykreslená ve viewportu (Solid) v prohlížeči.
**DoD:** `100_viewport.sh` → screenshot vs `out/reference/cube_solid.png`,
rozdíl < 2 % pixelů (tolerance je pevná, neměnit).

## M11 🖱️ UI a vstup (≈5–10 nocí)
**Cíl:** Blender UI (header, panely, outliner) se vykreslí; myš a klávesnice fungují
(orbit, výběr, G/R/S, Tab do edit mode).
**DoD:** `110_ui.sh` → automatizovaný scénář (Playwright klikne/stiskne klávesy) změní
pozici objektu, uloží .blend a `validate_blend.py` potvrdí novou pozici.
+ ruční checklist v PR pro Lukáše.
**Navíc (dotyk/tablet):** bez myši nejde orbit (prostřední tlačítko). Namapovat
tah dvěma prsty → MMB drag (orbit), pinch → kolečko (zoom), dlouhý dotyk → pravé tlačítko.
Řešit v JS vrstvě nebo GHOST, ne v jádru Blenderu.

## M12 🧱 Soubory a UX (≈2–4 noci)
**Cíl:** otevřít .blend z disku, uložit, stáhnout, OPFS „rozdělaná práce“ přežije reload.
**DoD:** `120_files.sh` → `FILES OK` + ruční test.

## M13 🎨 iPad / Safari a velikost (stretch)
**Cíl:** spustí se v Safari na iPadu (malá scéna), velikost a čas načtení změřené.
**DoD:** ruční test Lukáše + `out/size-report.txt`.

---

### Pravidla pro milníky
- Agent si na začátku milníku rozepíše **3–8 úkolů** do STATUS.md, každý na jednu noc.
- Odhady nocí jsou orientační. Když milník trvá 2× déle, agent napíše do LOG.md proč.
- Stage se přidá do `ci-stages.txt` až když jednou projde.
