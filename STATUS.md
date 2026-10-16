# STATUS

Výsledek noci: 🟡 částečně — headless Blender v Node agentovi běžel, ale stage `50_headless` v závěrečném CI neprošla → M5 ještě NENÍ hotový (2026-10-16, upraveno Claude v chatu)

## Aktuální milník
**CURRENT: M5 — Headless Blender ve wasm (bez Pythonu)** — zbývá jen spolehlivě projít `50_headless`

## Úkoly aktuálního milníku
- [ ] M5.6 **Opravit `scripts/stages/50_headless.sh`, aby prošla i v CI** (`scripts/ci.sh 50_headless`).
      V běhu 2026-10-16 agentovi prošla (build z cache, `ninja: no work to do`), ale v závěrečném
      CI spadla po 92 s. Ověř po `scripts/prepare_blender.sh --reset` + `ninja blender`.
      Až projde → přidej do `ci-stages.txt`, M5 DONE, pak M6.
- Plán M6 (až po M5):
- [ ] M6.1 Zjistit verzi Pythonu pro Blender 5.2.2 a přeložit CPython pro wasm64 (`scripts/build_python.sh`, do `deps/wasm`)
- [ ] M6.2 Přidat Python do `blender_wasm_options.cmake` (`WITH_PYTHON=ON`), configure projde
- [ ] M6.3 Přeložit a slinkovat Blender s Pythonem, `--version` v Node
- [ ] M6.4 Python skript v Node otevře cube.blend, přidá objekt, uloží `out/roundtrip.blend`
- [ ] M6.5 Stage `60_python.sh` + `tests/validate_blend.py` v desktop Blenderu: `VALID .blend: 2 objects`

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M6.1: CPython pro wasm64 (nejdřív poradit s `architect`: wasm64 + CPython Tools/wasm).

## Potřebuju od tebe (Lukáši)
- nic (2026-10-15: ADR-0003 wasm64 **schváleno**; cache pro `deps/` a `build-wasm/` workflow už má — viz LESSONS.md)

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M4 — Závislosti (2026-10-15): `DEPS OK` (16 knihoven, `out/deps.txt`)
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
