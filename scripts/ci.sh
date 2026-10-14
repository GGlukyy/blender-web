#!/usr/bin/env bash
# Runs every stage listed in ci-stages.txt, in order. Stops at the first failure.
# Usage: scripts/ci.sh            (all enabled stages)
#        scripts/ci.sh 10_toolchain   (one stage, even if not enabled yet)
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p out

run_stage() {
  local name="$1" script="scripts/stages/$1.sh"
  [[ -x "$script" ]] || { echo "STAGE MISSING: $script"; return 1; }
  echo "::group::stage $name"
  local start=$SECONDS
  if "$script" 2>&1 | tee "out/stage-$name.log"; then
    echo "::endgroup::"
    echo "STAGE PASS: $name ($((SECONDS - start))s)"
  else
    echo "::endgroup::"
    echo "STAGE FAIL: $name ($((SECONDS - start))s) — log: out/stage-$name.log"
    return 1
  fi
}

if [[ $# -gt 0 ]]; then
  run_stage "$1"
  exit $?
fi

while IFS= read -r line; do
  line="${line%%#*}"; line="$(echo "$line" | xargs)"
  [[ -z "$line" ]] && continue
  run_stage "$line"
done < ci-stages.txt

echo "CI ALL PASS"
