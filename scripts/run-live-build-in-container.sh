#!/usr/bin/env bash
set -e

echo "== Loading LB config =="
echo "== PLATFORM: $PLATFORM =="
echo "== Running inside container =="

ROOT=/workspace
WORK="$ROOT/build/work/$PLATFORM"

COMMON_DIR=/workspace/config/common/lb-config-switches.d
PLATFORM_DIR=/workspace/config/platform/$PLATFORM/lb-config-switches.d

set -a  # auto-export all variables

if [ -d "$COMMON_DIR" ]; then
  for f in "$COMMON_DIR"/*.conf; do
    [ -f "$f" ] && source "$f"
  done
fi

if [ -d "$PLATFORM_DIR" ]; then
  for f in "$PLATFORM_DIR"/*.conf; do
    [ -f "$f" ] && source "$f"
  done
fi

set +a  # stop auto-export

echo "== Effective config =="
env | grep ^LB_ || true

lb config noauto
lb build

if [ -d "$WORK" ]; then
  chown -R "$HOST_UID:$HOST_GID" "$WORK"
fi

if [ -d "$ROOT/dist" ]; then
  chown -R "$HOST_UID:$HOST_GID" "$ROOT/dist"
fi
