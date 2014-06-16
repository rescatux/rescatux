#!/bin/bash
# Rescapp make_rescatux_hybrid script
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
IS_HYBRID=".hybrid"
MEDIA_STR="cdrom_usb_hybrid"
FILE_EXTENSION="iso"
XFE_PACKAGES="fontconfig-config \
 libdrm2 \
 libexpat1 \
 libfontconfig1 \
 libfox-1.6-0 \
 libfreetype6 \
 libgl1-mesa-glx \
 libglapi-mesa \
 libglu1-mesa \
 libjbig0 libjpeg8 \
 libpng12-0 \
 libtiff4 \
 libx11-6 \
 libx11-data \
 libx11-xcb1 \
 libxau6 \
 libxcb-glx0 \
 libxcb1 \
 libxcursor1 \
 libxdamage1 \
 libxdmcp6 \
 libxext6 \
 libxfixes3 \
 libxft2 \
 libxrender1 \
 libxxf86vm1 \
 ttf-dejavu-core \
 ucf \
 xfe"
LXDE_PACKAGES="network-manager-gnome feh"
PYTHON_PACKAGES="python-sip python-qt4"
RAID_PACKAGES="dmraid"
LVM_PACKAGES="lvm2"
SYNAPTIC_PACKAGES="synaptic"
GKSU_PACKAGES="gksu"
GPARTED_PACKAGES="gparted gpart"
BOOTREPAIR_PACKAGES="boot-repair \
 boot-sav \
 gawk \
 pastebinit \
 xz-utils \
 gettext-base \
 glade2script \
 os-prober \
 parted \
 xdg-utils \
 zenity \
 boot-sav-extra \
 gksu \
 lsb-release \
 zip \
 dmraid \
 lvm2 \
 mbr \
 mdadm \
 os-uninstaller \
 clean-ubiquity \
 python \
 gir1.2-gtk-3.0 \
 python-gi
 "
TESTDISK_PACKAGES="testdisk \
 e2fslibs \
 libc6 \
 libcomerr2 \
 libjpeg8 \
 libncursesw5 \
 libntfs10 \
 libtinfo5 \
 libuuid1 \
 zlib1g \
 "
CRYPTSETUP_PACKAGES="cryptsetup \
 libcryptsetup4 \
 cryptsetup-bin \
 "


PACKAGES="${LXDE_PACKAGES} \
 ${PYTHON_PACKAGES} \
 ${RAID_PACKAGES} \
 ${LVM_PACKAGES} \
 ${SYNAPTIC_PACKAGES} \
 ${GKSU_PACKAGES} \
 ${GPARTED_PACKAGES} \
 ${BOOTREPAIR_PACKAGES} \
 ${TESTDISK_PACKAGES} \
 ${XFE_PACKAGES} \
 ${CRYPTSETUP_PACKAGES} \
 zenity \
 iceweasel \
 xchat \
 syslinux \
 pastebinit \
 mbr \
 ntfs-3g \
 chntpw \
 samdump2 \
 bkhive \
 gawk\
 extundelete\
 " # I add syslinux so that isohybrid command is recognised.
BOOT_OPTION="-b iso-hybrid"
LINUX_FLAVOURS="amd64 486"
source make_common
