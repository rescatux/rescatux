#!/bin/bash
# This script assumes apt-get install live-helper has been done
# This script assumes that the user has sudo permissions on lh build
IS_HYBRID="-hybrid"
MEDIA_STR="cdrom_usb_hybrid"
FILE_EXTENSION="iso"
GNOME_MINIMAL_PACKAGES="gdm3 gedit gnome-menus gnome-panel gnome-terminal nautilus"
PACKAGES="${GNOME_MINIMAL_PACKAGES} zenity iceweasel xchat wmctrl syslinux" # I add syslinux so that isohybrid command is recognised.
BOOT_OPTION="-b iso-hybrid"
LINUX_FLAVOURS="486 amd64"
source make_common
