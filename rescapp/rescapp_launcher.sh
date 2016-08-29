#!/bin/bash
# Rescapp launcher script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
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

# Main program
DEFAULT_PATH="${HOME}/Desktop/rescapp/"

RESCATUX_PATH=${DEFAULT_PATH}
export RESCATUX_PATH # Make it available to run scripts

RESCATUX_LIB_FILE="${DEFAULT_PATH}/rescatux_lib.sh"
export RESCATUX_LIB_FILE # Make it available to run scripts
export RESCATUX_VERSION="$(head -n 1 ${RESCATUX_PATH}/VERSION)"


source ${RESCATUX_LIB_FILE}
LOG_DIRECTORY="log"
export LOG_DIRECTORY # Make it available to run scripts
LIST_FILE_SUFFIX="lis"
GRUB_INSTALL_TO_MBR_STR="Restore GRUB / Fix Linux Boot"
CHAT_STR="Get online human help (chat)"
DOC_STR="Access online Rescatux website"

RUN_CODE="run"
LOCAL_DOC_CODE="localdoc"
ONLINE_DOC_CODE="onlinedoc"

LOCAL_DOC_STR="Local Documentation"
ONLINE_DOC_STR="Online Documentation"

RUN_FILE_STR="run"
LOCAL_FILE_STR="local_doc.html"
ONLINE_FILE_STR="online_doc.html"
DIRECTORY_FILE_STR="directory"
NAME_FILE_STR="name"
DESCRIPTION_FILE_STR="description"
ONLINE_DOC_URL="http://git.berlios.de/cgi-bin/cgit.cgi/rescatux/plain"

RESCAPP_TITLE_STR="RESCATUX's RESCAPP"


cd ${DEFAULT_PATH}

DIRECTORY=$1
SUDO="sudo -E"
[ -e ${DIRECTORY}/sudo ] || SUDO=""
exec ${SUDO} ${DIRECTORY}/${RUN_FILE_STR} > ${LOG_DIRECTORY}/${DIRECTORY}_log.txt 2>&1
