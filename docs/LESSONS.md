# Lessons learned (READ EVERY NIGHT)

Short, permanent lessons. One bullet each. Add a bullet when you lose >15 min to something
that could happen again. Never delete bullets; mark outdated ones with ~~strikethrough~~.

## Build & tools
- Never run `ninja` in Bash in the background with `&` — the tool kills it after ~30 min.
  Use `setsid nohup ninja … > out/build.log 2>&1 &` and poll the log, or run it in the foreground in chunks.
- Changing a header included everywhere (e.g. `MEM_guardedalloc.h`) rebuilds all of Blender (~35 min).
  Put stubs/shims in a NEW .c/.cc file instead, and ask the `architect` subagent if unsure.
- Use `em++` (not `emcc`) when linking C++ code.
- Blender 5.x needs 64-bit pointers → we build **wasm64** (`-sMEMORY64=1`, ADR-0003). wasm64 needs Node ≥ 24 (`$EMSDK_NODE`).
- Blender 5.2 uses **SDL3**, not SDL2 (ADR-0002).
- Build tools (makesdna, datatoc…) run in Node with `-sNODERAWFS=1`.

## Process
- A test passing on a **cached build is not proof**. `build-wasm/` may contain binaries from older,
  unmerged runs. Before claiming a milestone, make sure `ninja` actually rebuilt from the current
  patch (the workflow now resets `./blender` to tag + patch at start). If `ninja: no work to do`
  right after a reset, double-check that your fixes are really in `patches/blender-web.patch`.
- Workflow caches `deps/` and `build-wasm/` between runs (keys start with `build-`). If they look
  missing, write it in STATUS.md "Potřebuju od tebe" — do not edit workflows.

- Agent v CI dřív končil po 5–7 min, i když měl hodiny času (ukončil se sám). Teď to hlídá Stop hook `tools/stop_guard.sh` (`.github/agent/claude-settings.json`): dokud zbývá > 45 min, konec odmítne. Když tě zastaví, neber to jako chybu — vezmi další úkol.
- `.gitignore` s `deps/` ignoruje i `patches/deps/`. Používej kořenové `/deps/`. Cokoli, co existuje jen v cache (ruční úpravy v `deps/src`), se ztratí — vždy ulož jako `patches/deps/*.diff` a ověř čistým rebuildem.
- Web Blender v Node potřebuje `BLENDER_SYSTEM_RESOURCES` (`source scripts/web_resources.sh`): datafiles + scripts + python home. Bez toho Python/fonty spadnou.
- Emscripten `-fignore-exceptions`: jakýkoli `throw` v C++ = `Aborted(undefined)`. Zjistíš kde: relink s `--profiling-funcs` do /tmp (`ninja -t commands bin/blender.js`), pak stack trace má jména funkcí.
- Relink s názvy funkcí pro web: v `out/web/link.sh` dej `--profiling-funcs` PŘED `-o` (ne za něj), jinak se flag ztratí a stack v Chrome má jen čísla.
- `add_definitions(-DWITH_X)` v `gpu/CMakeLists.txt` platí jen pro knihovnu gpu — `creator` ho nevidí (proto nemáme `--gpu-backend webgpu`; backend se vybere sám, je jediný).
- OCIO/OIIO `throw` při PNG/thumbnail: nastav `OIIO_DISABLE_BUILTIN_OCIO_CONFIGS=1` z JS před startem (ENV, ne setenv uvnitř) — ADR-0005.
- SDL3 port (Emscripten) má EM_ASM, co není wasm64-safe (BigInt vs Number): vlastní kurzor → vypnuto v GHOST pod `__EMSCRIPTEN__`.
