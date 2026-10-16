#!/usr/bin/env bash
# M4: all libraries Blender needs are built for wasm into deps/wasm and listed in out/deps.txt.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/setup_emsdk.sh >/dev/null
scripts/prepare_blender.sh >/dev/null
scripts/build_deps.sh

P=deps/wasm
VERS=blender/build_files/build_environment/cmake/versions.cmake
mkdir -p out
: > out/deps.txt
# name:version-key:static library
while IFS=: read -r name key lib; do
  [[ -s "$P/lib/$lib" ]] || { echo "MISSING: $P/lib/$lib"; exit 1; }
  v="$(grep -E "^set\(${key}_VERSION " "$VERS" | head -1 | sed -E 's/^set\([A-Z0-9_]+ +//; s/\) *(#.*)?$//')"
  printf '%-14s %-12s %s (%s bytes)\n' "$name" "${v:-?}" "$lib" "$(stat -c %s "$P/lib/$lib")" >> out/deps.txt
done <<'LIBS'
brotli:BROTLI:libbrotlidec.a
freetype:FREETYPE:libfreetype.a
zstd:ZSTD:libzstd.a
imath:IMATH:libImath-3_2.a
openexr:OPENEXR:libOpenEXR-3_4.a
libdeflate:DEFLATE:libdeflate.a
openjph:OPENJPH:libopenjph.a
expat:EXPAT:libexpat.a
yaml-cpp:YAMLCPP:libyaml-cpp.a
pystring:PYSTRING:libpystring.a
minizip-ng:MINIZIPNG:libminizip.a
opencolorio:OPENCOLORIO:libOpenColorIO.a
libjpeg-turbo:JPEG:libjpeg.a
libpng:PNG:libpng16.a
libtiff:TIFF:libtiff.a
openimageio:OPENIMAGEIO:libOpenImageIO.a
fmt:FMT:libfmt.a
LIBS
echo "eigen        $(grep -E '^set\(EIGEN_VERSION ' "$VERS" | awk '{print $2}' | cut -c1-8) (header-only)" >> out/deps.txt
echo "emscripten ports: zlib sdl3 (EMSDK $(cat emsdk/.installed-version))" >> out/deps.txt
cat out/deps.txt
test -f "$P/include/Eigen/Core" || test -f "$P/include/eigen3/Eigen/Core"
echo "DEPS OK"
