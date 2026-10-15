# STATUS

Výsledek noci: ✅ pokrok — M1–M4 hotové, M5 rozpracovaný (všechno se přeloží do wasm64, chybí poslední link) (2026-10-15)

## Aktuální milník
**CURRENT: M5 — Headless Blender ve wasm (bez Pythonu)**

## Úkoly aktuálního milníku
- [x] M5.0 Rozhodnutí wasm64 (ADR-0003): wasm32 nejde, Blender 5.x potřebuje 64bitové ukazatele
- [x] M5.1 `bf_blenlib`, makesdna, datatoc a generátory se přeloží a spustí v Node
- [x] M5.2 Všechny `bf_*` knihovny se přeloží (2170 kroků, 0 chyb překladu)
- [~] M5.3 Link `blender.js/.wasm`: 1. pokus padl na 3 věcech, všechny opravené v patchi (initial memory 256MB, `malloc_stats`, `BPY_string_compile_check` bez Pythonu) — **druhý link ještě neběžel**, noc došla
- [ ] M5.4 Spustit v Node: `blender -b --version`
- [ ] M5.5 Stage `50_headless.sh`: načíst `cube.blend`, exit 0

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M5: spustit `ninja blender` (po změně hlavičky v guardedalloc se přeloží vše znovu, ~35 min s ccache), vyřešit případné další undefined symbols, pak `--version` v Node.
- Build: `source emsdk/emsdk_env.sh && cd build-wasm && ninja blender` (cca 60–90 min na 4 jádrech).

## Potřebuju od tebe (Lukáši)
- Schválit/zvážit ADR-0003 (wasm64): Chrome to umí, **Safari/iPad zatím ne**.
- Zvážit cache pro `deps/` a `build-wasm/` v workflow (já workflow nesmím měnit).

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M4 — Závislosti (2026-10-15): `DEPS OK` (16 knihoven, `out/deps.txt`)
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
