#!/usr/bin/env bash
set -e

ROOT=$(git rev-parse --show-toplevel)

. "$ROOT/distro.conf"

for dir in $ROOT/build/work/*; do

  PLATFORM=$(basename $dir)
  ARCH=$(echo $PLATFORM | cut -d- -f1)

  ISO=$(ls $dir/live-image-*.iso 2>/dev/null || true)
  IMG=$(ls $dir/live-image-*.img 2>/dev/null || true)

  if [ -f "$ISO" ]; then
    mv "$ISO" "$ROOT/dist/rescatux-$VERSION-$ARCH.iso"
  fi

  if [ -f "$IMG" ]; then
    IMG_FILENAME="rescatux-$VERSION-$ARCH-usb.img"
    mv "$IMG" "$ROOT/dist/${IMG_FILENAME}"

    if zip -q -j "$ROOT/dist/${IMG_FILENAME}.zip" "$ROOT/dist/${IMG_FILENAME}"; then
      rm "$ROOT/dist/${IMG_FILENAME}"
    else
      echo "Error: zip failed, keeping original file." >&2
      exit 1
    fi
  fi

done
