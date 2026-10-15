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
