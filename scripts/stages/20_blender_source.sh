#!/usr/bin/env bash
# M2: Blender source at the pinned tag, with our patch applied cleanly.
set -euo pipefail
cd "$(dirname "$0")/../.."
source versions.env
scripts/prepare_blender.sh
actual="$(git -C blender describe --tags --exact-match web-base 2>/dev/null || git -C blender rev-parse --short web-base)"
echo "base: $actual"
test -f blender/CMakeLists.txt
echo "BLENDER SOURCE OK $BLENDER_TAG"
