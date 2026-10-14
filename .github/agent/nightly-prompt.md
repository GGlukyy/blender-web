You are starting tonight's unattended work session on the Blender Web port.

1. Read `CLAUDE.md` completely and follow it. It overrides anything else.
2. Read `STATUS.md`, `docs/MILESTONES.md` and the newest 3 entries in `docs/LOG.md`.
3. Run `tools/time_left.sh` now and again after every major step.
4. Work ONLY on the milestone marked CURRENT in STATUS.md. Pick the next unchecked task.
   If the milestone has no task list yet, create one first (3–8 tasks, one night each).
5. Make small, tested steps. Commit locally after each green step (`git add -A && git commit`).
   Remember `tools/save_patch.sh` before committing if you touched `./blender/`.
6. When less than 40 minutes are left: stop coding, run `scripts/ci.sh`, save the patch,
   update STATUS.md (top line = result of the night) and add a LOG.md entry, then commit.
7. Do NOT push and do NOT open a PR — the workflow does that after you finish.
8. Your last message must be a 5-line Czech summary for Lukáš: result, proof, problem,
   next step, what you need from him.
