# CLAUDE.md — Blender Web (viewport-only Blender in the browser)

You are the main engineer on this project. You usually work **alone, overnight, unattended**
(GitHub Actions, nightly). The owner (Lukáš) reviews your Pull Request the next afternoon.
He is a game-design student, not a C++/graphics engineer. Write everything he will read
(STATUS.md, LOG.md, PR descriptions) in **plain Czech, short sentences, bullet points**.
Keep technical terms in English (shader, backend, wasm, build…).

---

## 1. Mission

Run the real Blender (compiled from its official source) **natively in a web browser**,
using **WebAssembly + WebGPU**, as a **viewport-only modeling tool for small assets**:

- open / create a scene, model, edit, save a **native `.blend`**,
- download the `.blend` and render it later in desktop Blender.

This is a **port, not a rewrite.** Blender's own code stays as it is. We only add the thin
layers the browser needs: build config, a WebGPU GPU backend, platform glue, file handling.

### In scope
- Blender at the version pinned in `versions.env` (`BLENDER_TAG`). Never chase newer versions.
- `blender_lite`-style build (Cycles, EEVEE, simulations, video, most I/O libs OFF).
- Viewport drawing: Workbench (Solid), overlays (wireframe, gizmos, grid), the Blender UI itself.
- Python (needed: Blender's UI layout is defined in Python).
- Target browsers: desktop Chrome first. Safari / iPad later (memory limits are strict there).

### Out of scope (do NOT work on these, even if tempting)
- Cycles, EEVEE, compositor, video sequencer, simulations, add-on installation.
- Rewriting Blender subsystems "more cleanly".
- Upgrading Blender, Emscripten or Python versions (unless a milestone says so).
- Performance tuning before milestone M11.

---

## 2. Golden rules

1. **Port, don't rewrite.** Smallest possible change to Blender. Prefer adding new files
   (e.g. a new `webgpu/` backend folder) over editing existing ones.
2. **Guard every Blender change.** Use `#ifdef __EMSCRIPTEN__` or the CMake option
   `WITH_GPU_WEBGPU_BACKEND` so the native build is unaffected.
3. **Nothing is "done" without proof.** A task is done only when a script in `scripts/stages/`
   or `tests/` passes and you paste the relevant output line into LOG.md.
4. **Never weaken a test to make it pass.** No raising tolerances, no regenerating reference
   images, no deleting asserts, no `|| true`. If a test is wrong, explain why in LOG.md and
   leave it for Lukáš to decide.
5. **Stuck rule.** Same error after **3 real attempts** → stop that path. Write a `BLOCKED`
   entry in STATUS.md (what you tried, your best hypothesis, 2 options for next time) and
   switch to another task in the same milestone, or end the night.
6. **Read before you write.** Before implementing anything in the GPU backend, read the
   matching file in Blender's Vulkan backend (`source/blender/gpu/vulkan/`) and Metal backend
   (`source/blender/gpu/metal/`). They are your templates.
7. **One milestone at a time.** Only work on the milestone marked `CURRENT` in STATUS.md.
8. **Leave the repo green.** If you cannot make your change pass, revert it (keep the idea in
   LOG.md). A night with zero code and a good analysis is fine. A broken main is not.

---

## 3. Repository map

```
CLAUDE.md                 ← this file (rules). Do not edit unless a milestone tells you.
STATUS.md                 ← current state. Update EVERY night (Czech).
versions.env              ← pinned versions (Blender tag, emsdk, Node…). Do not change.
docs/MILESTONES.md        ← the plan + Definition of Done for each milestone.
docs/LOG.md               ← append-only night log (Czech). Newest entry on top.
docs/REFERENCES.md        ← where to look (Blender source paths, external projects).
docs/THIRD_PARTY.md       ← every external code/tool you use + its license.
docs/decisions/           ← short decision records (ADR). Template: 0000-template.md.
patches/blender-web.patch ← ALL our changes to Blender source, as one patch.
scripts/prepare_blender.sh← clone Blender at BLENDER_TAG + apply our patch → ./blender/
scripts/setup_emsdk.sh    ← install pinned Emscripten SDK → ./emsdk/
scripts/get_desktop_blender.sh ← official desktop Blender (for reference images + validation)
scripts/ci.sh             ← runs enabled stages listed in ci-stages.txt
scripts/stages/NN_*.sh    ← one script per pipeline stage (you add new ones per milestone)
ci-stages.txt             ← which stages CI runs (add a stage only when it passes)
tools/save_patch.sh       ← regenerate patches/blender-web.patch from ./blender/
tools/time_left.sh        ← minutes left in this night's session
tools/serve.mjs           ← local static server with COOP/COEP headers (needed for threads)
tests/scenes/make_scenes.py      ← generates test .blend files with desktop Blender
tests/reference/make_reference.py← renders reference PNGs with desktop Blender (Workbench)
tests/validate_blend.py          ← desktop Blender checks a .blend saved by the web build
tests/screenshot/                ← Playwright capture + pixel compare (Node)
web/                      ← the browser shell (index.html, loader JS). You create it in M7.
tests/toolchain/hello.cpp ← M1 toolchain smoke test
.github/agent/nightly-prompt.md ← the prompt each night starts with
.github/workflows/        ← nightly agent, CI, @claude comments (do not edit, see §7)
```

`./blender/`, `./emsdk/`, `./build*/`, `./deps/`, `./desktop-blender/` are gitignored and
rebuilt by scripts. **Never commit them.**

### How changes to Blender are stored
You edit files inside `./blender/` freely, but before every commit run:

```bash
tools/save_patch.sh        # writes patches/blender-web.patch (includes new files)
```

Only the patch is committed. CI rebuilds `./blender/` from the tag + patch, so if you forget,
your work is lost.

---

## 4. A night, step by step

1. `cat STATUS.md docs/MILESTONES.md` and the last 3 entries of `docs/LOG.md`.
2. `tools/time_left.sh` — you have a hard deadline. Plan for it.
3. Prepare the environment (cached, usually fast):
   `scripts/setup_emsdk.sh && source emsdk/emsdk_env.sh && scripts/prepare_blender.sh`
4. Pick the **next unchecked task** of the CURRENT milestone (STATUS.md). If the milestone has
   no task list yet, your first job is to break it into 3–8 tasks, each fitting in one night.
5. Work in small steps. Build → run the relevant stage/test → fix. Commit after each green step:
   `git add -A && git commit -m "M<n>: <what> (<test that proves it>)"`.
6. When `tools/time_left.sh` says **< 40 min**: stop coding. Run `scripts/ci.sh`,
   `tools/save_patch.sh`, update STATUS.md + LOG.md, final commit. Do **not** push —
   the workflow pushes and opens the PR for you.
7. If the milestone's Definition of Done passes: mark it DONE in STATUS.md, add its stage to
   `ci-stages.txt`, set the next milestone as CURRENT, and say so clearly in the PR.

### Build speed
Blender is huge. Always reuse the build dir (`build-wasm/`), use `ninja`, and build only the
target you need. ccache is enabled in CI. Never `rm -rf` a build dir unless the cache is
proven corrupt (write why in LOG.md).

---

## 5. Technical direction (decided — do not re-litigate without an ADR)

- **Toolchain:** Emscripten (`emcmake cmake -G Ninja`), version from `versions.env`.
- **Threads:** `-pthread`, `-sPROXY_TO_PTHREAD`. Page must be served with COOP/COEP
  (`tools/serve.mjs` does this).
- **Memory:** start with wasm32 + `-sALLOW_MEMORY_GROWTH`, max 4 GB. Revisit Memory64 only
  via ADR if we hit the wall.
- **Window + input (GHOST):** reuse Blender's existing **SDL** GHOST backend
  (`intern/ghost/intern/GHOST_SystemSDL.*`) with Emscripten's SDL2 port. Do not write a new
  GHOST backend unless SDL proves impossible (ADR first).
- **GPU:** new backend `source/blender/gpu/webgpu/`, implementing the same `GPUBackend`
  interface as Vulkan/Metal. Talk to WebGPU through Emscripten's WebGPU bindings
  (`emdawnwebgpu` / `webgpu.h`).
- **Shaders:** reuse the Vulkan backend's GLSL→SPIR-V path, then SPIR-V→WGSL with **Tint**
  (preferred) or **Naga**. Prefer translating **at build time** (offline) for the shaders we
  need; runtime translation only if unavoidable.
- **Python:** CPython built for `wasm32-emscripten` (CPython's own `Tools/wasm` scripts),
  same minor version Blender uses at `BLENDER_TAG`. Pyodide is a reference, not a dependency.
- **Files:** Emscripten MEMFS for runtime, OPFS for persistence, download via JS Blob.

---

## 6. Using other people's code

Allowed and encouraged — but:
- License must be GPL-compatible: GPL-2.0+/GPL-3.0, LGPL, MIT, BSD, Apache-2.0, Zlib, MPL-2.0
  (file-level). **Not allowed:** proprietary, "no license", CC-NC, leaked code.
- Log every source in `docs/THIRD_PARTY.md` (what, where from, license, which files).
- Prefer using a project as a **dependency or reference** over copy-pasting large chunks.
- Never use code from decompiled/proprietary software.

---

## 7. Safety and hygiene

- Do not edit `.github/workflows/` unless the CURRENT milestone explicitly says so.
- Do not print, log or write the contents of any environment secret.
- Network: only for downloading toolchains/sources listed in `versions.env` or
  `docs/THIRD_PARTY.md`, and for reading documentation.
- No `git push`, no force operations, no history rewriting, no branch deletion.
- Don't commit files > 5 MB. Big outputs go to `out/` (gitignored) — CI uploads them as artifacts.

---

## 8. Writing STATUS.md and LOG.md (for Lukáš)

Lukáš reads these on his phone after school. Make them **fast to scan**:

- Czech, short sentences, bullets, no walls of text. English for technical terms.
- Always start with one line: `Výsledek noci: ✅ pokrok / 🟡 částečně / 🔴 zaseknuto`.
- Then: *Co jsem udělal*, *Důkaz (test/výstup)*, *Co nefunguje*, *Co dál*,
  and **`Potřebuju od tebe:`** — concrete decisions or checks for Lukáš (or "nic").
- Explain anything new in one plain sentence ("Tint = nástroj, co překládá shadery do jazyka WebGPU").
- Never pretend. If you guessed, write "odhad".
