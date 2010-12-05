#!/bin/bash
# This script assumes apt-get install live-helper has been done
# This script assumes that the user has sudo permissions on lh build
MEDIA_STR="usb"
FILE_EXTENSION="img"
PACKAGES="zenity iceweasel xchat wmctrl"
BOOT_OPTION="-b usb-hdd"
source make_common

