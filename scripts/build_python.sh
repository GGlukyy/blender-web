#!/usr/bin/env bash
# M6.1: CPython (version pinned by Blender's versions.cmake) as static libs for wasm64 → deps/wasm.
# Step 1: native "build python" (cross-compile needs the same version). Step 2: Emscripten wasm64.
# Source patch: patches/deps/python-wasm64.diff (trampoline needs BigInt on wasm64).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
source emsdk/emsdk_env.sh >/dev/null 2>&1
PREFIX="$ROOT/deps/wasm"
VERS="$ROOT/blender/build_files/build_environment/cmake/versions.cmake"
PYV="$(grep -E '^set\(PYTHON_VERSION ' "$VERS" | sed -E 's/set\(PYTHON_VERSION +([0-9.]+)\).*/\1/')"
SRC="$ROOT/deps/src/python"
if [[ ! -f "$SRC/configure" ]]; then
  rm -rf "$SRC" "$SRC.tmp"; mkdir -p "$SRC.tmp"
  curl -fsSL --retry 3 "https://www.python.org/ftp/python/$PYV/Python-$PYV.tar.xz" | tar -xJ -C "$SRC.tmp" --strip-components=1
  mv "$SRC.tmp" "$SRC"
fi
if [[ ! -f "$SRC/.wasm64-patched" ]]; then
  patch -p1 -N -d "$SRC" < "$ROOT/patches/deps/python-wasm64.diff"
  touch "$SRC/.wasm64-patched"
fi
[[ -f "$PREFIX/.done-python" ]] && { echo "python already built ($PYV)"; exit 0; }

NATIVE="$ROOT/deps/build/python-host"
if [[ ! -x "$NATIVE/python" ]]; then
  mkdir -p "$NATIVE"; (cd "$NATIVE" && env -u CC -u CXX "$SRC/configure" -q && make -j"$(nproc)" >/dev/null)
fi

W="$ROOT/deps/build/python-wasm"; rm -rf "$W"; mkdir -p "$W"; cd "$W"
export CONFIG_SITE="$SRC/Tools/wasm/config.site-wasm32-emscripten"
CFLAGS="-pthread -O2 -DPY_CALL_TRAMPOLINE -DSSIZE_MAX=LONG_MAX" \
LDFLAGS="-pthread -sSTACK_SIZE=8MB -sDEFAULT_PTHREAD_STACK_SIZE=8MB" \
emconfigure "$SRC/configure" --host=wasm64-unknown-emscripten --build="$("$SRC/config.guess")" \
  --with-build-python="$NATIVE/python" --prefix="$PREFIX" --with-emscripten-target=node \
  --enable-wasm-pthreads --disable-shared --without-ensurepip --disable-test-modules \
  --without-system-libmpdec \
  py_cv_module__bz2=n/a py_cv_module__ctypes=n/a py_cv_module__sqlite3=n/a \
  py_cv_module__lzma=n/a py_cv_module__uuid=n/a
emmake make -j"$(nproc)" all
emmake make install
# Side archives, under unique names (lib/libexpat.a is the OCIO one).
rm -f "$PREFIX/lib/libexpat_py.a" "$PREFIX/lib/libmpdec_py.a"
cp Modules/_decimal/libmpdec/libmpdec.a "$PREFIX/lib/libpython3.13-mpdec.a"
cp Modules/expat/libexpat.a             "$PREFIX/lib/libpython3.13-expat.a"
cp Modules/_hacl/libHacl_Hash_SHA2.a    "$PREFIX/lib/libpython3.13-hacl.a"
touch "$PREFIX/.done-python"
echo "PYTHON OK: $PYV $(stat -c %s "$PREFIX/lib/libpython3.13.a") bytes"
