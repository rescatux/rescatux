#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
OUT="$ROOT/build/deps/live-boot"

mkdir -p "$OUT"

# Build image
docker build -t rescatux-live-boot builder/live-boot

# Extract .deb artifacts
docker run --rm \
  -v "$OUT:/out" \
  rescatux-live-boot
