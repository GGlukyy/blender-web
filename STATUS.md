# STATUS

Výsledek noci: ✅ pokrok — M1, M2 a M3 hotové (2026-10-15)

## Aktuální milník
**CURRENT: M4 — Závislosti pro wasm**

## Úkoly aktuálního milníku
- [ ] M4.1 Zjistit, které knihovny build opravdu potřebuje (z `build.ninja` / include chyb): zstd, fmt, eigen, OIIO, OCIO, OpenEXR, Imath, epoxy…
- [ ] M4.2 Skript `scripts/build_deps.sh`: header-only (fmt, eigen) + zstd do `build-wasm/wasm-deps`
- [ ] M4.3 OpenEXR/Imath pro wasm
- [ ] M4.4 OpenColorIO a OpenImageIO pro wasm (nejtěžší; zvážit minimální build)
- [ ] M4.5 Stage `40_deps.sh` → `DEPS OK` + `out/deps.txt`

## Zaseknuto (BLOCKED)
- nic

## Co dál
- M4: přeložit závislosti pro wasm.

## Potřebuju od tebe (Lukáši)
- nic

## Hotové milníky
- M0 — Kostra repa a CI (2026-10-14)
- M1 — Toolchain (2026-10-15): `HELLO FROM WASM, threads=OK`
- M3 — CMake configure (2026-10-15): `CONFIGURE OK`
- M2 — Zdroják + reference (2026-10-15): `BLENDER SOURCE OK v5.2.2`, `REFERENCES OK`
