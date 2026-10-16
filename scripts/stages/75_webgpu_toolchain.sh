#!/usr/bin/env bash
# M8 de-risk: wasm64 + pthread + OffscreenCanvas + emdawnwebgpu clears a canvas to #FF00FF in headless Chrome
# (standalone test, not Blender yet). Decision record: docs/decisions/0004-webgpu-main-loop.md
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
source emsdk/emsdk_env.sh >/dev/null 2>&1
(cd tests/screenshot && [[ -d node_modules/playwright ]] || PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install --no-audit --no-fund >/dev/null)
mkdir -p out/webgpu_mt
em++ tests/webgpu/clear.cpp --use-port=emdawnwebgpu -sMEMORY64=1 -pthread -sPROXY_TO_PTHREAD \
  -sOFFSCREENCANVAS_SUPPORT=1 "-sOFFSCREENCANVASES_TO_PTHREAD=#canvas" -sEXIT_RUNTIME=0 -o out/webgpu_mt/index.html
node tests/webgpu/shot.mjs out/webgpu_mt out/webgpu_mt/shot.png "WEBGPU CLEAR SUBMITTED"
(cd tests/screenshot && node color_check.mjs ../../out/webgpu_mt/shot.png '#FF00FF' 2) | tee out/webgpu_color.log
grep -q 'COLOR OK' out/webgpu_color.log
echo "WEBGPU TOOLCHAIN OK"
