# STATUS

Výsledek noci: ✅ pokrok — M5 HOTOVÝ (headless Blender běží ve wasm v Node), M6 (Python) rozpracovaný jen jako plán (2026-10-16)

## Aktuální milník
**CURRENT: M6 — Python ve wasm + roundtrip .blend**

## Úkoly aktuálního milníku
- [ ] M6.1 Zjistit verzi Pythonu pro Blender 5.2.2 a přeložit CPython pro wasm64 (`scripts/build_python.sh`, do `deps/wasm`)
- [ ] M6.2 Přidat Python do `blender_wasm_options.cmake` (`WITH_PYTHON=ON`), configure projde
- [ ] M6.3 Přeložit a slinkovat Blender s Pythonem, `--version` v Node
- [ ] M6.4 Python skript v Node otevře cube.blend, přidá objekt, uloží `out/roundtrip.blend`
- [ ] M6.5 Stage `60_python.sh` + `tests/validate_blend.py` v desktop Blenderu: `VALID .blend: 2 objects`

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M6.1: CPython pro wasm64 (nejdřív poradit s `architect`: wasm64 + CPython Tools/wasm).
- M5: spustit `ninja blender` (po změně hlavičky v guardedalloc se přeloží vše znovu, ~35 min s ccache), vyřešit případné další undefined symbols, pak `--version` v Node.
- Build: `source emsdk/emsdk_env.sh && cd build-wasm && ninja blender` (cca 60–90 min na 4 jádrech).

## Potřebuju od tebe (Lukáši)
- nic (2026-10-15: ADR-0003 wasm64 **schváleno**; cache pro `deps/` a `build-wasm/` workflow už má — viz LESSONS.md)

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M5 — Headless Blender (2026-10-16): `HEADLESS OK: Blender 5.2.2 LTS, cube.blend loaded, exit 0`
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M4 — Závislosti (2026-10-15): `DEPS OK` (16 knihoven, `out/deps.txt`)
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
