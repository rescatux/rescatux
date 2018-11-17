#!/bin/bash
# Rescatux make-rescatux-sg2d (hybrid) script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
#
# Rescatux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescatux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescatux.  If not, see <http://www.gnu.org/licenses/>.

# SG2 STUFF
SG2D_SOURCE_DIRECTORY="../../sgd/git/supergrub2/"
RESCATUX_SOURCE_PWD=`pwd`
SG2D_EXTRA_DIR="$(pwd)/sg2d-extra"
RESCATUX_RELEASE_DIR="$(pwd)/rescatux-release"
BOOT_ISOS_DIRECTORY="boot-isos"
ORIGINAL_GRUB_CFG_BACKUP="original_grub_cfg_backup.cfg"
# RESCATUX STUFF
# Fetch version from folder directory name
VERSION=`head -1 VERSION`
ARCH="i386"
RESCATUX_STR="rescatux"
MEDIA_STR="cdrom_usb_hybrid"
LINUX_FLAVOURS="amd64 486"
RESCATUX_MEDIA_STR="${RESCATUX_STR}_${MEDIA_STR}"
FILE_EXTENSION="iso"
BASE_FILENAME="rescatux-$(head -n 1 VERSION)"

ORIGINAL_RESCATUX_ISO="${BASE_FILENAME}.${FILE_EXTENSION}"
SG2D_RESCATUX_ISO=${BASE_FILENAME}_sg2d.${FILE_EXTENSION}

RESCATUX_LOGOS_SRC="logos-src"
RESCATUX_LOGOS="logos"

cd ${SG2D_SOURCE_DIRECTORY}
if [ -e ${BOOT_ISOS_DIRECTORY}/${ORIGINAL_RESCATUX_ISO} ] ; then
  rm ${BOOT_ISOS_DIRECTORY}/${ORIGINAL_RESCATUX_ISO}
fi

if [ ! -d ${BOOT_ISOS_DIRECTORY} ] ; then
  mkdir ${BOOT_ISOS_DIRECTORY}
fi
cd ${BOOT_ISOS_DIRECTORY}
cp ${RESCATUX_SOURCE_PWD}/${ORIGINAL_RESCATUX_ISO} \
${ORIGINAL_RESCATUX_ISO}
cd ..
cp menus/grub.cfg ${ORIGINAL_GRUB_CFG_BACKUP}
cp ${RESCATUX_SOURCE_PWD}/${RESCATUX_LOGOS}/background.png menus
cp ${SG2D_EXTRA_DIR}/unicode.pf2 menus
cp ${SG2D_EXTRA_DIR}/rescatux-theme.txt menus
sed -e "s/RESCATUX_ISO_TO_REPLACE/${ORIGINAL_RESCATUX_ISO}/g" ${SG2D_EXTRA_DIR}/rescatux_grub.cfg > menus/grub.cfg
./supergrub-mkrescue -o=${RESCATUX_RELEASE_DIR}/${SG2D_RESCATUX_ISO}
cp ${ORIGINAL_GRUB_CFG_BACKUP} menus/grub.cfg
rm ${BOOT_ISOS_DIRECTORY}/${ORIGINAL_RESCATUX_ISO}
rm menus/background.png
rm menus/unicode.pf2
rm menus/rescatux-theme.txt

cd ${RESCATUX_RELEASE_DIR}
md5sum ${SG2D_RESCATUX_ISO} > ${SG2D_RESCATUX_ISO}.md5
cp ${BASE_FILENAME}.packages ${SG2D_RESCATUX_ISO}.packages
cd ${RESCATUX_SOURCE_PWD}
