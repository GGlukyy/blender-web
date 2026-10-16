#!/usr/bin/env bash
# M6: web Blender (wasm + Python) opens cube.blend, adds an object, saves;
# DESKTOP Blender then validates the saved file.
set -euo pipefail
cd "$(dirname "$0")/../.."
source versions.env
scripts/setup_emsdk.sh >/dev/null
source emsdk/emsdk_env.sh >/dev/null 2>&1
scripts/prepare_blender.sh >/dev/null
scripts/build_python.sh >/dev/null
(cd build-wasm && ninja blender)
[[ -s out/scenes/cube.blend ]] || scripts/stages/25_references.sh
scripts/get_desktop_blender.sh >/dev/null

source scripts/web_resources.sh

B="$PWD/build-wasm/bin/blender.js"
timeout 300 "$EMSDK_NODE" "$B" -b --python-expr "import sys;print('PYEXPR',sys.version.split()[0])" > out/py_expr.log 2>&1
grep -q '^PYEXPR 3.13.13' out/py_expr.log

rm -f out/roundtrip.blend
timeout 600 "$EMSDK_NODE" "$B" -b "$PWD/out/scenes/cube.blend" --python tests/web/roundtrip.py -- "$PWD/out/roundtrip.blend" 2>&1 | tee out/roundtrip.log
test -s out/roundtrip.blend

RUN=(desktop-blender/blender -b --factory-startup)
if command -v xvfb-run >/dev/null; then RUN=(xvfb-run -a "${RUN[@]}"); fi
"${RUN[@]}" out/roundtrip.blend --python tests/validate_blend.py -- --expect-objects 2 --expect-location WebCube 3 0 0 | tee out/validate.log
grep -q 'VALID .blend: 2 objects' out/validate.log
echo "PYTHON ROUNDTRIP OK"
