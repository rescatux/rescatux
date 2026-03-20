#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
OUT="$ROOT/build/deps"

mkdir -p "$OUT"

cd "$ROOT/external/live-build"

dpkg-buildpackage -us -uc

mv ../live-build_*.deb "$OUT/"

