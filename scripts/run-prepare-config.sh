#!/usr/bin/env bash
set -e

PLATFORM=$1
ARCH=$(echo $PLATFORM | cut -d- -f1)

ROOT=$(git rev-parse --show-toplevel)
IMAGE="rescatux-builder-$ARCH"

HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
  --privileged \
  -e HOST_UID=$HOST_UID \
  -e HOST_GID=$HOST_GID \
  -e PLATFORM=$PLATFORM \
  -v "$ROOT:/workspace" \
  -w "/workspace" \
  $IMAGE /workspace/scripts/prepare-config-in-container.sh