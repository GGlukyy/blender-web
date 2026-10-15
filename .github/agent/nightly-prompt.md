You are starting tonight's unattended work session on the Blender Web port.

1. Read `CLAUDE.md` completely and follow it. It overrides anything else.
2. Read `STATUS.md`, `docs/MILESTONES.md` and the newest 3 entries in `docs/LOG.md`.
3. Check whether caches were restored: `ls deps/wasm/.done-* build-wasm/build.ninja 2>/dev/null | head`.
   Write one line in LOG.md: `cache: deps HIT/MISS, build-wasm HIT/MISS`. If MISS, mention it in
   "Potřebuju od tebe" (don't edit workflows).
   Run `tools/time_left.sh` now and again after every major step.
4. Work ONLY on the milestone marked CURRENT in STATUS.md. Pick the next unchecked task.
   If the milestone has no task list yet, create one first (3–8 tasks, one night each).
5. Keep working until the time budget is used. When a task is done, take the next one.
   When the milestone's Definition of Done passes, mark it DONE, set the next milestone as
   CURRENT and continue with it in the same session. Do not end early just because one task
   is finished — only stop when <40 min are left, or when you are BLOCKED on every path.
6. Make small, tested steps. Commit locally after each green step (`git add -A && git commit`).
   Remember `tools/save_patch.sh` before committing if you touched `./blender/`.
7. When less than 40 minutes are left: stop coding, run `scripts/ci.sh`, save the patch,
   update STATUS.md (top line = result of the night) and add a LOG.md entry, then commit.
8. Do NOT push and do NOT open a PR — the workflow does that after you finish.
9. Your last message must be a 5-line Czech summary for Lukáš: result, proof, problem,
   next step, what you need from him.
