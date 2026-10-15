#!/usr/bin/env bash
# M3: emcmake cmake with the lite wasm configuration finishes without errors.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
# shellcheck disable=SC1091
source emsdk/emsdk_env.sh >/dev/null 2>&1
scripts/prepare_blender.sh >/dev/null

mkdir -p build-wasm out
(cd build-wasm && emcmake cmake -G Ninja -C ../scripts/blender_wasm_options.cmake ../blender)

grep -E '^WITH_[A-Z0-9_]+:BOOL=' build-wasm/CMakeCache.txt | sort > out/cmake-options.txt
test -s out/cmake-options.txt
test -f build-wasm/build.ninja
# the options that define this port must really be set
grep -q '^WITH_CYCLES:BOOL=OFF' out/cmake-options.txt
grep -q '^WITH_PYTHON:BOOL=OFF' out/cmake-options.txt
grep -q '^WITH_GHOST_SDL:BOOL=ON' out/cmake-options.txt
echo "CONFIGURE OK"
