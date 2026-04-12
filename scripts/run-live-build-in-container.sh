#!/usr/bin/env bash
set -e

echo "== Loading LB config =="
echo "== PLATFORM: $PLATFORM =="
echo "== Running inside container =="

COMMON_DIR=/workspace/config/common/lb-config-switches.d
PLATFORM_DIR=/workspace/config/platform/$PLATFORM/lb-config-switches.d

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

export $(env | grep '^LB_' | cut -d= -f1)

echo "== Effective config =="
env | grep ^LB_ || true

lb config noauto
lb build
