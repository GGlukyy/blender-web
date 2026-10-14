#!/usr/bin/env bash
# Downloads the official desktop Blender (Linux x64) into ./desktop-blender.
# Used ONLY for: generating test scenes, reference images, validating .blend files.
set -euo pipefail
cd "$(dirname "$0")/.."
source versions.env

if [[ -x desktop-blender/blender ]]; then
  echo "desktop Blender present: $(desktop-blender/blender --version | head -1)"
  exit 0
fi

mkdir -p desktop-blender
echo "Downloading $DESKTOP_BLENDER_URL"
curl -fL --retry 3 "$DESKTOP_BLENDER_URL" -o desktop-blender.tar.xz
tar -xJf desktop-blender.tar.xz -C desktop-blender --strip-components=1
rm desktop-blender.tar.xz
desktop-blender/blender --version | head -1
