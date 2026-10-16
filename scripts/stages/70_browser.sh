#!/usr/bin/env bash
# M7: the same roundtrip as M6, but in headless Chrome (wasm + MEMFS), then desktop Blender validates.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
source emsdk/emsdk_env.sh >/dev/null 2>&1
scripts/prepare_blender.sh >/dev/null
scripts/build_python.sh >/dev/null
[[ -s out/scenes/cube.blend ]] || scripts/stages/25_references.sh
scripts/get_desktop_blender.sh >/dev/null
scripts/link_web.sh
cp web/index.html out/web/index.html
cp out/scenes/cube.blend out/web/cube.blend
cp tests/web/roundtrip.py out/web/roundtrip.py
(cd tests/screenshot && [[ -d node_modules/playwright ]] || PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install --no-audit --no-fund >/dev/null)

rm -f out/web_roundtrip.blend
node tests/web/browser_roundtrip.mjs out/web out/web_roundtrip.blend 2>&1 | tee out/browser.log
test -s out/web_roundtrip.blend

RUN=(desktop-blender/blender -b --factory-startup)
if command -v xvfb-run >/dev/null; then RUN=(xvfb-run -a "${RUN[@]}"); fi
"${RUN[@]}" out/web_roundtrip.blend --python tests/validate_blend.py -- --expect-objects 2 --expect-location WebCube 3 0 0 | tee out/validate_browser.log
grep -q 'VALID .blend: 2 objects' out/validate_browser.log
echo "BROWSER ROUNDTRIP OK"
