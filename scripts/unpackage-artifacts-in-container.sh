#!/usr/bin/env bash
set -e

ROOT=$(pwd)
PLATFORM=${1:-}

if [ -z "$PLATFORM" ]; then
  echo "Usage: $0 <platform>" >&2
  exit 1
fi

. "$ROOT/distro.conf"

dir="$ROOT/build/work/$PLATFORM"

if [ ! -d "$dir" ]; then
  echo "Error: missing build workspace for platform $PLATFORM" >&2
  exit 1
fi

PLATFORM=$(basename $dir)
ARCH=$(echo $PLATFORM | cut -d- -f1)
TYPE=$(echo $PLATFORM | cut -d- -f2)

ISO_TARGET="$ROOT/dist/rescatux-$VERSION-$ARCH.iso"
IMG_ZIP_TARGET="$ROOT/dist/rescatux-$VERSION-$ARCH-usb.img.zip"
IMG_TARGET="$ROOT/dist/rescatux-$VERSION-$ARCH-usb.img"

mkdir -p "$dir"

if [ -f "$ISO_TARGET" ]; then
  ISO_DEST="$dir/live-image-$ARCH.iso"
  echo ">> Moving $ISO_TARGET to $ISO_DEST"
  mv "$ISO_TARGET" "$ISO_DEST"
  chown "$HOST_UID:$HOST_GID" "$ISO_DEST"
fi

if [ -f "$IMG_ZIP_TARGET" ]; then
  IMG_DEST="$dir/live-image-$ARCH.img"
  echo ">> Unzipping $IMG_ZIP_TARGET to $IMG_DEST"
  unzip -q -o "$IMG_ZIP_TARGET" -d "$dir"
  chown "$HOST_UID:$HOST_GID" "$IMG_DEST"
fi

if [ -f "$IMG_TARGET" ] && [ ! -f "$IMG_ZIP_TARGET" ]; then
  IMG_DEST="$dir/live-image-$ARCH.img"
  echo ">> Moving $IMG_TARGET to $IMG_DEST"
  mv "$IMG_TARGET" "$IMG_DEST"
  chown "$HOST_UID:$HOST_GID" "$IMG_DEST"
fi