#!/bin/bash
# Rescapp make_rescatux_hybrid_i486 script
# Copyright (C) 2012 Adrian Gibanel Lopez
#
# Rescapp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescapp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescapp.  If not, see <http://www.gnu.org/licenses/>.

# This script assumes apt-get install live-helper has been done
# This script assumes that the user has sudo permissions on lh build
IS_HYBRID="-hybrid"
MEDIA_STR="cdrom_usb_hybrid"
FILE_EXTENSION="iso"
PACKAGES="zenity iceweasel xchat wmctrl syslinux" # I add syslinux so that isohybrid command is recognised.
BOOT_OPTION="-b iso-hybrid"
LINUX_FLAVOURS="486"
source make_common
