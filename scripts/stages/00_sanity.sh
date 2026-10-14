#!/usr/bin/env bash
# M0: repo structure and basic tooling are in place.
set -euo pipefail
cd "$(dirname "$0")/../.."

required=(CLAUDE.md STATUS.md versions.env ci-stages.txt docs/MILESTONES.md docs/LOG.md
          docs/THIRD_PARTY.md scripts/prepare_blender.sh scripts/setup_emsdk.sh
          tools/save_patch.sh tools/time_left.sh tools/serve.mjs)
for f in "${required[@]}"; do
  [[ -e "$f" ]] || { echo "missing: $f"; exit 1; }
done

# shell scripts must parse
for s in scripts/*.sh scripts/stages/*.sh tools/*.sh; do
  bash -n "$s" || { echo "syntax error: $s"; exit 1; }
done

# every enabled stage must exist
while IFS= read -r line; do
  line="${line%%#*}"; line="$(echo "$line" | xargs)"
  [[ -z "$line" ]] && continue
  [[ -x "scripts/stages/$line.sh" ]] || { echo "enabled stage missing or not executable: $line"; exit 1; }
done < ci-stages.txt

# versions must be set
source versions.env
for v in BLENDER_TAG EMSDK_VERSION DESKTOP_BLENDER_URL; do
  [[ -n "${!v:-}" ]] || { echo "versions.env: $v is empty"; exit 1; }
done

echo "SANITY OK"
