#!/usr/bin/env bash
# M6.1: CPython 3.13 for wasm64 builds (scripts/build_python.sh) and runs in Node.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
source emsdk/emsdk_env.sh >/dev/null 2>&1
scripts/prepare_blender.sh >/dev/null
scripts/build_python.sh
export PYTHONHOME="$PWD/deps/wasm"
OUT="$(timeout 300 "$EMSDK_NODE" deps/build/python-wasm/python.js -c \
 "import sys,os,re,json,enum,zlib,decimal,hashlib,threading,pyexpat;t=threading.Thread(target=print,args=('THREAD',));t.start();t.join();print('PY OK',sys.version.split()[0],sys.maxsize>2**32)" 2>&1)"
echo "$OUT"
grep -q 'PY OK 3.13.13 True' <<<"$OUT"
echo "PYTHON RUNS OK"
