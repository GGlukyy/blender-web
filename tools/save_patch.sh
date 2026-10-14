#!/usr/bin/env bash
# Writes ALL changes in ./blender (edits + NEW files) relative to the pristine tag
# into patches/blender-web.patch. Run before every commit (CLAUDE.md §3).
set -euo pipefail
cd "$(dirname "$0")/.."
[[ -d blender/.git ]] || { echo "no ./blender — nothing to save"; exit 0; }

git -C blender add -A                     # include new files
git -C blender diff --cached --binary web-base > patches/blender-web.patch
lines=$(wc -l < patches/blender-web.patch)
files=$(git -C blender diff --cached --name-only web-base | wc -l)
echo "PATCH SAVED: $files files, $lines lines → patches/blender-web.patch"
