# STATUS

Výsledek noci: ✅ pokrok — M1 a M2 hotové (2026-10-15)

## Aktuální milník
**CURRENT: M3 — Konfigurace CMake pro wasm**

## Úkoly aktuálního milníku
- [ ] M3.1 Zjistit, co `emcmake cmake` na Blenderu hlásí (chybějící deps, library/ složka)
- [ ] M3.2 Lite konfigurace (vypnout Cycles, EEVEE, OpenVDB, FFmpeg…) v `scripts/blender_wasm_options.cmake`
- [ ] M3.3 ADR v `docs/decisions/` co je vypnuté a proč
- [ ] M3.4 Stage `30_configure.sh` → `CONFIGURE OK` + `out/cmake-options.txt`

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M3: lite konfigurace CMake pro wasm.

## Potřebuju od tebe (Lukáši)
- nic

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
