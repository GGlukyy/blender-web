# STATUS

Výsledek noci: ✅ pokrok — M1–M4 hotové (2026-10-15)

## Aktuální milník
**CURRENT: M5 — Headless Blender ve wasm (bez Pythonu)**

## Úkoly aktuálního milníku
- [ ] M5.1 Přeložit první Blender knihovny (`ninja bf_blenlib`, `bf_dna`, …) a opravit chyby
- [ ] M5.2 Přeložit všechny `bf_*` knihovny (bez Pythonu, bez GPU)
- [ ] M5.3 Slinkovat `blender.js/.wasm`
- [ ] M5.4 Spustit v Node: `blender -b --version`
- [ ] M5.5 Stage `50_headless.sh`: načíst `cube.blend`, exit 0

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M5: první překlad samotného Blenderu (`ninja` v `build-wasm/`).

## Potřebuju od tebe (Lukáši)
- nic

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M4 — Závislosti (2026-10-15): `DEPS OK` (16 knihoven, `out/deps.txt`)
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
