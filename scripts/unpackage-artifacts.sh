#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
PLATFORM=${1:-}

if [ -z "$PLATFORM" ]; then
  echo "Usage: $0 <platform>" >&2
  exit 1
fi

HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
  -e HOST_UID=$HOST_UID \
  -e HOST_GID=$HOST_GID \
  -v "$ROOT:/workspace" \
  -w "/workspace" \
  rescatux-builder-amd64 /workspace/scripts/unpackage-artifacts-in-container.sh "$PLATFORM"