#!/usr/bin/env bash
# M1: pinned Emscripten compiles a threaded C++ program that runs in Node.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
# shellcheck disable=SC1091
source emsdk/emsdk_env.sh >/dev/null 2>&1

mkdir -p out/toolchain
em++ tests/toolchain/hello.cpp -O1 -pthread -sPROXY_TO_PTHREAD -sEXIT_RUNTIME=1 \
  -o out/toolchain/hello.js
node out/toolchain/hello.js | tee out/toolchain/run.txt
grep -q "HELLO FROM WASM, threads=OK" out/toolchain/run.txt

# wasm64 (Memory64) is what the Blender port uses (ADR-0003); needs Node >= 24 from emsdk.
em++ tests/toolchain/hello.cpp -O1 -pthread -sMEMORY64=1 -sPROXY_TO_PTHREAD -sEXIT_RUNTIME=1 \
  -o out/toolchain/hello64.js
"$EMSDK_NODE" out/toolchain/hello64.js | tee out/toolchain/run64.txt
grep -q "HELLO FROM WASM, threads=OK" out/toolchain/run64.txt
echo "TOOLCHAIN OK"
