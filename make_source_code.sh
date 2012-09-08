#!/bin/bash
# Rescapp make_source_code script
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

set -x
set -v

CURRENT_FOLDER=$PWD
BASE_FILENAME="rescatux_source_code_`head -n 1 VERSION`"
TEMP_FOLDER_PRE="/tmp/$$"
TEMP_FOLDER="${TEMP_FOLDER_PRE}/${BASE_FILENAME}"
SOURCE_CODE_FILE="VERSION README COPYING Makefile rescapp.py order.py rescapp.sh.desktop make_source_code.sh make_rescatux_cd.sh make_rescatux_hybrid_amd64.sh make_rescatux_hybrid_i486.sh make_rescatux_hybrid.sh make_rescatux_usb.sh make_common chat web grub-install update-grub grub.lis grub rescatux.lis log show_log support support.lis logo images setbackground.sh setbackground.sh.desktop about.lis about about-rescapp rescatux_lib.sh share_log win.lis win winmbr winpass fs fs.lis fsck bootinfoscript share_log_forum rescapp_launcher.sh help-rescapp pass.lis pass chpasswd sudoers"
mkdir --parents $TEMP_FOLDER
cp -r ${SOURCE_CODE_FILE} $TEMP_FOLDER
cd ${TEMP_FOLDER_PRE}
tar czf ${BASE_FILENAME}.tar.gz ${BASE_FILENAME}
mv ${TEMP_FOLDER_PRE}/${BASE_FILENAME}.tar.gz $CURRENT_FOLDER
