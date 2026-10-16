#!/usr/bin/env bash
# M7.1: relink the (already compiled) Blender for the BROWSER: same objects, different link flags
# (no Node/NODERAWFS, MEMFS) → out/web/blender.{js,wasm,data}. Compile flags are identical, so no recompile.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"
source emsdk/emsdk_env.sh >/dev/null 2>&1
OUT="$ROOT/out/web"; mkdir -p "$OUT"
( cd build-wasm && ninja blender >/dev/null )   # objects up to date
CMD="$(cd build-wasm && ninja -t commands bin/blender.js | tail -1)"
python3 - "$CMD" "$OUT" > "$OUT/link.sh" <<'PY'
import sys
s, out = sys.argv[1], sys.argv[2]
a = s.index(': && ') + 5
b = s.index(' && sh -c')
c = s[a:b]
c = c.replace('-sENVIRONMENT=node', '-sENVIRONMENT=web,worker').replace('-sNODERAWFS=1', '-sFORCE_FILESYSTEM=1').replace('-sEXIT_RUNTIME=1', '-sEXIT_RUNTIME=0')
c = c.replace('-o bin/blender.js', f'-sEXPORTED_RUNTIME_METHODS=FS,callMain,ENV -o {out}/blender.js')
print(c)
PY
( cd build-wasm && bash "$OUT/link.sh" 2>&1 | grep -v "warning:" || true )
test -s "$OUT/blender.wasm"

# Resources for MEMFS (slimmed): fonts+locale datafiles, scripts, python stdlib without tests/GUI.
RES="$OUT/resources"; rm -rf "$RES"; mkdir -p "$RES/python/lib"
cp -r blender/release/datafiles "$RES/datafiles"
cp -r blender/scripts "$RES/scripts"
cp -r deps/wasm/lib/python3.13 "$RES/python/lib/python3.13"
( cd "$RES/python/lib/python3.13" && rm -rf test idlelib tkinter ensurepip turtledemo lib2to3 config-3.13-wasm32-emscripten site-packages/__pycache__ \
  && find . -name __pycache__ -type d -prune -exec rm -rf {} + )
rm -rf "$RES/datafiles/locale" "$RES/datafiles/studiolights" "$RES/scripts/templates_osl" "$RES/scripts/freestyle"
python3 "$EMSDK/upstream/emscripten/tools/file_packager.py" "$OUT/blender.data" --preload "$RES@/resources" \
  --js-output="$OUT/blender.data.js" --no-node >/dev/null
du -sh "$OUT"/blender.*
echo "WEB LINK OK"
