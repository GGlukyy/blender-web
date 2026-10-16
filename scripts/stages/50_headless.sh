#!/usr/bin/env bash
# M5: headless Blender (no Python, no GPU) linked to wasm runs in Node.
set -euo pipefail
cd "$(dirname "$0")/../.."
source versions.env
scripts/setup_emsdk.sh >/dev/null
source emsdk/emsdk_env.sh >/dev/null 2>&1
scripts/prepare_blender.sh >/dev/null
(cd build-wasm && ninja blender)
test -s build-wasm/bin/blender.js

[[ -s out/scenes/cube.blend ]] || scripts/stages/25_references.sh

B="$PWD/build-wasm/bin/blender.js"
source scripts/web_resources.sh   # fonts, scripts, python home

# No `| head` here: with pipefail an early-closed pipe (SIGPIPE) would fail the stage randomly.
timeout 300 "$EMSDK_NODE" "$B" -b --version > out/version.log 2>&1
VER="$(head -1 out/version.log)"
echo "$VER"
[[ "$VER" == Blender\ ${BLENDER_TAG#v}* ]] || { echo "BAD VERSION"; exit 1; }

cd out/scenes
timeout 600 "$EMSDK_NODE" "$B" -b cube.blend 2>&1 | tee ../headless.log
grep -q 'Read blend' ../headless.log
echo "HEADLESS OK: $VER, cube.blend loaded, exit 0"
