#!/usr/bin/env bash
set -e

PLATFORM=$1
ARCH=$(echo $PLATFORM | cut -d- -f1)

ROOT=$(git rev-parse --show-toplevel)
WORK="$ROOT/build/work/$PLATFORM"
IMAGE="rescatux-builder-$ARCH"

HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
  --privileged \
  -e HOST_UID=$HOST_UID \
  -e HOST_GID=$HOST_GID \
  -v "$ROOT:/workspace" \
  -w "/workspace/build/work/$PLATFORM" \
  $IMAGE /workspace/scripts/run-live-build-in-container.sh
