#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
OUT="$ROOT/build/deps/live-build"
PLATFORM="linux/amd64"
PLATFORM_RUN_ARGS="--platform ${PLATFORM}"
PLATFORM_BUILD_ARGS="${PLATFORM_RUN_ARGS}"

mkdir -p "$OUT"

cd "$ROOT"
# Build image
docker buildx build --load ${PLATFORM_BUILD_ARGS} -t rescatux-live-build -f builder/live-build/Dockerfile .

# Extract .deb artifacts
docker run --rm \
  ${PLATFORM_RUN_ARGS} \
  -v "$OUT:/out" \
  rescatux-live-build
