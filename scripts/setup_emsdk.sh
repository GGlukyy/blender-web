#!/usr/bin/env bash
# Installs the pinned Emscripten SDK into ./emsdk (idempotent, cache-friendly).
# After running:  source emsdk/emsdk_env.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source versions.env

if [[ ! -d emsdk/.git ]]; then
  git clone --depth 1 https://github.com/emscripten-core/emsdk.git emsdk
fi

if [[ -f emsdk/.installed-version ]] && [[ "$(cat emsdk/.installed-version)" == "$EMSDK_VERSION" ]]; then
  echo "emsdk $EMSDK_VERSION already installed"
  exit 0
fi

(cd emsdk && git pull --ff-only || true)
emsdk/emsdk install "$EMSDK_VERSION"
emsdk/emsdk activate "$EMSDK_VERSION"
echo "$EMSDK_VERSION" > emsdk/.installed-version
echo "emsdk $EMSDK_VERSION installed. Run: source emsdk/emsdk_env.sh"
