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

---

## 2026-10-14 — M0 — ✅
- Co jsem udělal: spustil `scripts/ci.sh` (stage `00_sanity`).
- Důkaz: `SANITY OK` / `CI ALL PASS`
- Co nefunguje: nic; PR (druhá podmínka M0) ověří až existence tohoto PR.
- Co dál: když PR existuje → M0 DONE, M1 (toolchain) CURRENT.
- Potřebuju od tebe: potvrdit, že se PR otevřel.

---

## 2026-10-12 — setup — ✅
- Co jsem udělal: založena kostra repa (CLAUDE.md, milníky, skripty, workflowy).
- Důkaz: zatím nic neběželo — první test proběhne v první noci (M0).
- Co dál: první noční běh, M0.
- Potřebuju od tebe: projít `PRIPRAVA.md` a nastavit secret + Actions.
