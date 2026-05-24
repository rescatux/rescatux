#!/usr/bin/env bash
set -e

ROOT=$(pwd)
PLATFORM=${1:-}

if [ -z "$PLATFORM" ]; then
  echo "Usage: $0 <platform>" >&2
  exit 1
fi

. "$ROOT/distro.conf"

mkdir -p "$ROOT/dist"

created_files=()

track_created_file() {
  created_files+=("$1")
}

remove_created_file() {
  local path=$1
  local remaining=()
  local file

  for file in "${created_files[@]}"; do
    if [ "$file" != "$path" ]; then
      remaining+=("$file")
    fi
  done

  created_files=("${remaining[@]}")
}

chown_created_files() {
  local file

  for file in "${created_files[@]}"; do
    if [ -e "$file" ]; then
      chown "$HOST_UID:$HOST_GID" "$file"
    fi
  done
}

dir="$ROOT/build/work/$PLATFORM"

if [ ! -d "$dir" ]; then
  echo "Error: missing build workspace for platform $PLATFORM" >&2
  exit 1
fi

for dir in "$dir"; do

  PLATFORM=$(basename $dir)
  ARCH=$(echo $PLATFORM | cut -d- -f1)

  ISO=$(ls $dir/live-image-*.iso 2>/dev/null || true)
  IMG=$(ls $dir/live-image-*.img 2>/dev/null || true)

  if [ -f "$ISO" ]; then
    ISO_TARGET="$ROOT/dist/rescatux-$VERSION-$ARCH.iso"
    mv "$ISO" "$ISO_TARGET"
    track_created_file "$ISO_TARGET"
  fi

  if [ -f "$IMG" ]; then
    IMG_FILENAME="rescatux-$VERSION-$ARCH-usb.img"
    IMG_TARGET="$ROOT/dist/${IMG_FILENAME}"
    ZIP_TARGET="$IMG_TARGET.zip"

    mv "$IMG" "$IMG_TARGET"
    track_created_file "$IMG_TARGET"

    if zip -q -j "$ZIP_TARGET" "$IMG_TARGET"; then
      rm "$IMG_TARGET"
      remove_created_file "$IMG_TARGET"
      track_created_file "$ZIP_TARGET"
    else
      echo "Error: zip failed, keeping original file." >&2
      chown_created_files
      exit 1
    fi
  fi

done

chown_created_files
