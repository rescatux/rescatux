#!/usr/bin/env bash
set -e

PLATFORM=$PLATFORM
ROOT=/workspace

WORK="$ROOT/build/work/$PLATFORM"

# Clean
rm -rf "$WORK"
mkdir -p "$WORK"

# Copy config
cp -r "$ROOT/config/common" "$WORK/config"

cp -r "$ROOT/config/platform/$PLATFORM/"* "$WORK/config/" 2>/dev/null || true

# Fix ownership at the end
chown -R "$HOST_UID:$HOST_GID" "$WORK"
