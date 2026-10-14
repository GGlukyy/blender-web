#!/usr/bin/env bash
# M1: pinned Emscripten compiles a threaded C++ program that runs in Node.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
# shellcheck disable=SC1091
source emsdk/emsdk_env.sh >/dev/null 2>&1

mkdir -p out/toolchain
emcc tests/toolchain/hello.cpp -O1 -pthread -sPROXY_TO_PTHREAD -sEXIT_RUNTIME=1 \
  -o out/toolchain/hello.js
node out/toolchain/hello.js | tee out/toolchain/run.txt
grep -q "HELLO FROM WASM, threads=OK" out/toolchain/run.txt
echo "TOOLCHAIN OK"
