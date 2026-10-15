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
- Workflow caches `deps/` and `build-wasm/` between runs (keys start with `build-`). If they look
  missing, write it in STATUS.md "Potřebuju od tebe" — do not edit workflows.
