#!/bin/bash

# Main program
DEFAULT_PATH="${HOME}/Desktop/rescapp/"

RESCATUX_PATH=${DEFAULT_PATH}
export RESCATUX_PATH # Make it available to run scripts

RESCATUX_LIB_FILE="${DEFAULT_PATH}/rescatux_lib.sh"
export RESCATUX_LIB_FILE # Make it available to run scripts


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
