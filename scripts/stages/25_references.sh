#!/usr/bin/env bash
# M2: desktop Blender generates test scenes + Workbench reference images.
# Reference images are generated, never edited by hand (CLAUDE.md rule 4).
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/get_desktop_blender.sh
mkdir -p out/scenes out/reference

# Headless desktop Blender: Workbench needs a GPU context; on CI runners without a GPU
# we rely on software OpenGL (Mesa llvmpipe). xvfb-run provides a display.
RUN=(desktop-blender/blender -b --factory-startup)
if command -v xvfb-run >/dev/null; then RUN=(xvfb-run -a "${RUN[@]}"); fi

"${RUN[@]}" --python tests/scenes/make_scenes.py -- out/scenes
"${RUN[@]}" out/scenes/cube.blend --python tests/reference/make_reference.py -- out/reference/cube_solid.png

test -s out/scenes/cube.blend
test -s out/reference/cube_solid.png
echo "REFERENCES OK"
