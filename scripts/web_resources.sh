#!/usr/bin/env bash
# Source me: builds out/resources (datafiles + scripts from the Blender tree, python home from deps/wasm)
# and exports BLENDER_SYSTEM_RESOURCES for the wasm Blender running in Node.
R="$PWD/out/resources"; rm -rf "$R"; mkdir -p "$R"
ln -s "$PWD/blender/release/datafiles" "$R/datafiles"
ln -s "$PWD/blender/scripts" "$R/scripts"
ln -s "$PWD/deps/wasm" "$R/python"
export BLENDER_SYSTEM_RESOURCES="$R"
# OIIO asks OCIO for colorspace equivalents; OCIO throws, and exceptions are off in our wasm build (ADR-0005).
export OIIO_DISABLE_BUILTIN_OCIO_CONFIGS=1
