#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
OUT="$ROOT/build/deps/live-boot"
PLATFORM="linux/amd64"
PLATFORM_RUN_ARGS="--platform ${PLATFORM}"
PLATFORM_BUILD_ARGS="${PLATFORM_RUN_ARGS} --build-arg TARGETPLATFORM=${PLATFORM}"

mkdir -p "$OUT"

cd "$ROOT"
# Build image
docker buildx build ${PLATFORM_BUILD_ARGS} -t rescatux-live-boot -f builder/live-boot/Dockerfile .

# Extract .deb artifacts
docker run --rm \
  ${PLATFORM_RUN_ARGS} \
  -v "$OUT:/out" \
  rescatux-live-boot
