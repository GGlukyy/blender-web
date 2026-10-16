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
# Emscripten ports for wasm64 (zlib is found by FindZLIB in the sysroot, so build it up front).
embuilder build zlib freetype sdl3 --wasm64 >/dev/null 2>&1

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
# Emscripten's CMake toolchain only knows the wasm32 library dir; point FindZLIB at the wasm64 port.
SYSROOT="$ROOT/emsdk/upstream/emscripten/cache/sysroot"
CMAKE_COMMON=(-DZLIB_LIBRARY="$SYSROOT/lib/wasm64-emscripten/libz.a" -DZLIB_INCLUDE_DIR="$SYSROOT/include"
  -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX"
  -DCMAKE_PREFIX_PATH="$PREFIX" -DCMAKE_FIND_ROOT_PATH="$PREFIX" -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=OFF
  -DCMAKE_C_FLAGS="-pthread -sMEMORY64=1" -DCMAKE_CXX_FLAGS="-pthread -sMEMORY64=1"
  -DCMAKE_EXE_LINKER_FLAGS="-pthread -sMEMORY64=1")
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

dep_expat()   { build_cmake expat expat -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_BUILD_EXAMPLES=OFF -DEXPAT_BUILD_TESTS=OFF -DEXPAT_BUILD_DOCS=OFF -DEXPAT_SHARED_LIBS=OFF; }
dep_yamlcpp() { build_cmake yamlcpp . -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DYAML_CPP_BUILD_CONTRIB=OFF -DYAML_BUILD_SHARED_LIBS=OFF; }
dep_pystring() { # upstream has no CMakeLists; Blender ships one
  local d; d="$(fetch pystring)"
  cp "$ROOT/blender/build_files/build_environment/patches/cmakelists_pystring.txt" "$d/CMakeLists.txt"
  build_cmake pystring .
  mkdir -p "$PREFIX/include/pystring"; cp "$d/pystring.h" "$PREFIX/include/pystring/"
}
dep_minizipng() { build_cmake minizipng . -DMZ_COMPAT=ON -DMZ_ZLIB=ON -DMZ_BZIP2=OFF -DMZ_LZMA=OFF -DMZ_ZSTD=OFF -DMZ_LIBCOMP=OFF -DMZ_PKCRYPT=OFF -DMZ_WZAES=OFF -DMZ_OPENSSL=OFF -DMZ_ICONV=OFF -DMZ_SIGNING=OFF -DMZ_FETCH_LIBS=OFF -DMZ_FORCE_FETCH_LIBS=OFF; }

dep_opencolorio() { build_cmake opencolorio . -DOCIO_BUILD_APPS=OFF -DOCIO_BUILD_PYTHON=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_JAVA=OFF \
  -DOCIO_BUILD_DOCS=OFF -DOCIO_BUILD_TESTS=OFF -DOCIO_BUILD_GPU_TESTS=OFF -DOCIO_USE_SIMD=OFF -DOCIO_USE_SSE2=OFF \
  -DOCIO_USE_SSE3=OFF -DOCIO_USE_SSSE3=OFF -DOCIO_USE_SSE4=OFF -DOCIO_USE_SSE42=OFF -DOCIO_USE_AVX=OFF -DOCIO_USE_AVX2=OFF \
  -DOCIO_USE_F16C=OFF -DOCIO_USE_OPENEXR_HALF=ON -DOCIO_INSTALL_EXT_PACKAGES=NONE -DOCIO_WARNING_AS_ERROR=OFF \
  -Dexpat_ROOT="$PREFIX" -Dyaml-cpp_ROOT="$PREFIX" -Dpystring_ROOT="$PREFIX" -DImath_ROOT="$PREFIX" \
  -Dminizip-ng_INCLUDE_DIR="$PREFIX/include/minizip" -Dminizip-ng_LIBRARY="$PREFIX/lib/libminizip.a"; }

# FreeType with Brotli: Blender's UI fonts are WOFF2 (needs Brotli). The Emscripten freetype
# port has no Brotli, so we build both like Blender's build_environment does.
dep_brotli() { build_cmake brotli . -DBROTLI_DISABLE_TESTS=ON -DBROTLI_BUNDLED_MODE=OFF
  # 1.0.9 does not install its static libs (only shared ones); copy them with plain names.
  for l in brotlicommon brotlidec brotlienc; do cp "$BLD/brotli/lib$l-static.a" "$PREFIX/lib/lib$l.a"; done
  mkdir -p "$PREFIX/include/brotli"; cp "$SRC/brotli/c/include/brotli/"*.h "$PREFIX/include/brotli/"; }
dep_freetype() { build_cmake freetype . -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_PNG=ON \
  -DFT_REQUIRE_BROTLI=ON -DFT_REQUIRE_ZLIB=ON -DBROTLIDEC_INCLUDE_DIRS="$PREFIX/include" \
  -DBROTLIDEC_LIBRARIES="$PREFIX/lib/libbrotlidec.a;$PREFIX/lib/libbrotlicommon.a"; }

dep_jpeg() { build_cmake jpeg . -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DWITH_SIMD=OFF -DWITH_TURBOJPEG=OFF -DWITH_JAVA=OFF -DWITH_TOOLS=OFF -DWITH_TESTS=OFF -DWITH_FUZZ=OFF; }
dep_png() { build_cmake png . -DPNG_SHARED=OFF -DPNG_STATIC=ON -DPNG_TESTS=OFF -DPNG_TOOLS=OFF -DPNG_FRAMEWORK=OFF -DPNG_HARDWARE_OPTIMIZATIONS=OFF; }
dep_tiff() { build_cmake tiff . -Dtiff-tools=OFF -Dtiff-tests=OFF -Dtiff-contrib=OFF -Dtiff-docs=OFF -Dtiff-opengl=OFF \
  -Dlibdeflate=OFF -Dlzma=OFF -Dwebp=OFF -Dzstd=OFF -Djbig=OFF -Dlerc=OFF -Djpeg=OFF -Dold-jpeg=OFF -Dpixarlog=OFF -Dcxx=OFF; }
dep_robinmap() { build_cmake robinmap . -DBUILD_TESTING=OFF; }
dep_openimageio() {
  local d; d="$(fetch openimageio)"
  if [[ ! -f "$d/.blender-patched" ]]; then
    local pd="$ROOT/blender/build_files/build_environment/patches"
    patch -p1 -N -d "$d" < "$pd/openimageio.diff"
    patch -p1 -N -d "$d" < "$pd/openimageio_dds_3d_5133.diff"
    patch -p1 -N -d "$d" < "$ROOT/patches/deps/openimageio-emscripten.diff"
    touch "$d/.blender-patched"
  fi
  build_cmake openimageio . -DOIIO_BUILD_TOOLS=OFF -DOIIO_BUILD_TESTS=OFF -DBUILD_TESTING=OFF -DSTOP_ON_WARNING=OFF \
    -DUSE_PYTHON=OFF -DUSE_TBB=OFF -DUSE_QT=OFF -DUSE_NUKE=OFF -DUSE_OPENVDB=OFF -DUSE_FREETYPE=OFF -DUSE_DCMTK=OFF \
    -DUSE_GIF=OFF -DUSE_OPENCV=OFF -DUSE_OPENJPEG=OFF -DUSE_FFMPEG=OFF -DUSE_PTEX=OFF -DUSE_LIBHEIF=OFF -DUSE_LIBRAW=OFF \
    -DUSE_JXL=OFF -DUSE_WEBP=OFF -DUSE_OPENCOLORIO=ON -DUSE_SIMD=0 -Dlibjpeg-turbo_ROOT="$PREFIX" -DJPEG_ROOT="$PREFIX" -DINSTALL_DOCS=OFF \
    -DOpenImageIO_REQUIRED_DEPS="libjpeg-turbo;TIFF;OpenEXR;PNG;fmt;Robinmap;ZLIB;openjph"
}

ALL=(brotli freetype zstd fmt eigen imath deflate openjph openexr expat yamlcpp pystring minizipng opencolorio jpeg png tiff robinmap openimageio)
targets=("$@"); [[ ${#targets[@]} -eq 0 ]] && targets=("${ALL[@]}")
for t in "${targets[@]}"; do
  if [[ -f "$PREFIX/.done-$t" ]]; then echo "== $t already built"; continue; fi
  echo "== building $t"
  "dep_$t"
  touch "$PREFIX/.done-$t"
done
echo "DEPS BUILT: ${targets[*]}"
