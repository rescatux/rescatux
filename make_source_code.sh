#!/bin/bash
set -x
set -v

CURRENT_FOLDER=$PWD
BASE_FILENAME="rescatux_source_code_`head -n 1 VERSION`"
TEMP_FOLDER_PRE="/tmp/$$"
TEMP_FOLDER="${TEMP_FOLDER_PRE}/${BASE_FILENAME}"
SOURCE_CODE_FILE="VERSION README Makefile  rescapp.sh  rescapp.sh.desktop make_source_code.sh make_rescatux_cd.sh make_rescatux_hybrid_amd64.sh make_rescatux_hybrid_i486.sh make_rescatux_hybrid.sh make_rescatux_usb.sh make_common chat web grub-install update-grub grub.lis grub rescatux.lis log show_log support support.lis logo"
mkdir --parents $TEMP_FOLDER
cp -r ${SOURCE_CODE_FILE} $TEMP_FOLDER
cd ${TEMP_FOLDER_PRE}
tar czf ${BASE_FILENAME}.tar.gz ${BASE_FILENAME}
mv ${TEMP_FOLDER_PRE}/${BASE_FILENAME}.tar.gz $CURRENT_FOLDER
