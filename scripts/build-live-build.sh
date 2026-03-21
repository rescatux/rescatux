#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
OUT="$ROOT/build/deps"

mkdir -p "$OUT"

docker build -t rescatux-live-build builder/live-build

docker run --rm \
  -v "$OUT:/out" \
  rescatux-live-build
