#!/usr/bin/env bash
# Puts Blender source at BLENDER_TAG into ./blender and applies patches/blender-web.patch.
#
# Safe to re-run:
#   - If ./blender exists and has uncommitted work, it is LEFT ALONE (your work in progress).
#     Use --reset to throw local changes away and re-apply the saved patch.
set -euo pipefail
cd "$(dirname "$0")/.."
source versions.env
PATCH=patches/blender-web.patch
RESET=0
[[ "${1:-}" == "--reset" ]] && RESET=1

if [[ ! -d blender/.git ]]; then
  echo "Cloning Blender $BLENDER_TAG (shallow)…"
  git clone --depth 1 --branch "$BLENDER_TAG" "$BLENDER_GIT_URL" blender
  # Blender keeps some libraries/tests as submodules or LFS; we don't need the big ones.
  git -C blender config user.email "agent@localhost"
  git -C blender config user.name "blender-web-agent"
  # Mark the pristine tag as the base our patch is diffed against.
  git -C blender tag -f web-base HEAD
fi

if [[ $RESET -eq 1 ]]; then
  git -C blender reset --hard web-base
  git -C blender clean -fdq
fi

if [[ -n "$(git -C blender status --porcelain)" ]]; then
  echo "blender/ has local changes — keeping them (use --reset to discard)."
elif [[ -s "$PATCH" ]]; then
  echo "Applying $PATCH…"
  git -C blender apply --index --whitespace=nowarn "../$PATCH"
else
  echo "No patch yet — pristine Blender $BLENDER_TAG."
fi

echo "BLENDER SOURCE READY ($BLENDER_TAG)"
