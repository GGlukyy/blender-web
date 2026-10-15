#!/usr/bin/env bash
# M4: builds the libraries Blender needs for wasm into ./deps/wasm (prefix).
# Versions are taken from Blender's own build_files/build_environment/cmake/versions.cmake.
# Idempotent: each library leaves a marker deps/wasm/.done-<name>.
# Usage: scripts/build_deps.sh [name ...]     (default: all, in dependency order)
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
# shellcheck disable=SC1091
source emsdk/emsdk_env.sh >/dev/null 2>&1
VERS="$ROOT/blender/build_files/build_environment/cmake/versions.cmake"
PREFIX="$ROOT/deps/wasm"
SRC="$ROOT/deps/src"
BLD="$ROOT/deps/build"
mkdir -p "$PREFIX" "$SRC" "$BLD"

# ver NAME_FIELD → value from versions.cmake, ${X} references resolved for URI
ver() { grep -E "^set\($1 " "$VERS" | head -1 | sed -E 's/^set\([A-Z0-9_]+ +//; s/\) *(#.*)?$//'; }
resolve() { # resolve ${FOO_VERSION} inside a string
  local s="$1" v
  while [[ "$s" =~ \$\{([A-Z0-9_]+)\} ]]; do v="$(ver "${BASH_REMATCH[1]}")"; s="${s//\$\{${BASH_REMATCH[1]}\}/$v}"; done
  echo "$s"
}
fetch() { # fetch NAME → extracts into deps/src/NAME, prints dir
  local n="$1" up; up="$(echo "$n" | tr a-z A-Z)"
  local uri; uri="$(resolve "$(ver "${up}_URI")")"
  local dir="$SRC/$n"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir.tmp"
    curl -fsSL --retry 3 "$uri" -o "$dir.tmp/archive"
    tar -xf "$dir.tmp/archive" -C "$dir.tmp" --strip-components=1
    rm "$dir.tmp/archive"; mv "$dir.tmp" "$dir"
  fi
  echo "$dir"
}
CMAKE_COMMON=(-G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX"
  -DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_FIND_ROOT_PATH="$PREFIX" -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=OFF
  -DCMAKE_C_FLAGS="-pthread" -DCMAKE_CXX_FLAGS="-pthread")
build_cmake() { # build_cmake NAME SUBDIR extra-args…
  local n="$1" sub="$2"; shift 2
  local dir; dir="$(fetch "$n")"
  emcmake cmake -S "$dir/$sub" -B "$BLD/$n" "${CMAKE_COMMON[@]}" "$@"
  cmake --build "$BLD/$n" -j"$(nproc)"
  cmake --install "$BLD/$n"
}

dep_zstd()  { build_cmake zstd build/cmake -DZSTD_BUILD_PROGRAMS=OFF -DZSTD_BUILD_TESTS=OFF -DZSTD_BUILD_SHARED=OFF -DZSTD_MULTITHREAD_SUPPORT=OFF; }
dep_fmt()   { build_cmake fmt . -DFMT_TEST=OFF -DFMT_DOC=OFF; }
dep_eigen() { build_cmake eigen . -DEIGEN_BUILD_DOC=OFF -DBUILD_TESTING=OFF -DEIGEN_BUILD_BTL=OFF -DEIGEN_BUILD_PKGCONFIG=OFF -DEIGEN_BUILD_LAPACK=OFF -DEIGEN_BUILD_BLAS=OFF -DEIGEN_BUILD_DEMOS=OFF -DEIGEN_BUILD_TESTING=OFF; }
dep_imath() { build_cmake imath . -DBUILD_TESTING=OFF -DIMATH_INSTALL_PKG_CONFIG=OFF; }

dep_deflate() { build_cmake deflate . -DLIBDEFLATE_BUILD_SHARED_LIB=OFF -DLIBDEFLATE_BUILD_STATIC_LIB=ON -DLIBDEFLATE_BUILD_GZIP=OFF; }
dep_openjph() { build_cmake openjph . -DOJPH_BUILD_EXECUTABLES=OFF -DOJPH_BUILD_TESTS=OFF -DOJPH_ENABLE_TIFF_SUPPORT=OFF -DOJPH_DISABLE_SIMD=ON; }
dep_openexr() { build_cmake openexr . -DBUILD_TESTING=OFF -DOPENEXR_BUILD_TOOLS=OFF -DOPENEXR_INSTALL_EXAMPLES=OFF \
  -DOPENEXR_BUILD_EXAMPLES=OFF -DOPENEXR_FORCE_INTERNAL_DEFLATE=OFF -DOPENEXR_FORCE_INTERNAL_IMATH=OFF \
  -DOPENEXR_FORCE_INTERNAL_OPENJPH=OFF -DOPENEXR_ENABLE_THREADING=ON -DOPENEXR_INSTALL_PKG_CONFIG=OFF; }

ALL=(zstd fmt eigen imath deflate openjph openexr)
targets=("$@"); [[ ${#targets[@]} -eq 0 ]] && targets=("${ALL[@]}")
for t in "${targets[@]}"; do
  if [[ -f "$PREFIX/.done-$t" ]]; then echo "== $t already built"; continue; fi
  echo "== building $t"
  "dep_$t"
  touch "$PREFIX/.done-$t"
done
echo "DEPS BUILT: ${targets[*]}"
