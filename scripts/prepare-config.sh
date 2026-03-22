#!/usr/bin/env bash
set -e

PLATFORM=$1
ROOT=$(git rev-parse --show-toplevel)

WORK="$ROOT/build/work/$PLATFORM"

rm -rf "$WORK"
mkdir -p "$WORK"

cp -r "$ROOT/config/common" "$WORK/config"

cp -r "$ROOT/config/platform/$PLATFORM/"* "$WORK/config/" 2>/dev/null || true
