#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)
HOST_UID=$(id -u)
HOST_GID=$(id -g)

docker run --rm \
  -e HOST_UID=$HOST_UID \
  -e HOST_GID=$HOST_GID \
  -v "$ROOT:/workspace" \
  -w "/workspace" \
  rescatux-builder-amd64 /workspace/scripts/package-artifacts-in-container.sh
