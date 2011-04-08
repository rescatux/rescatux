#!/bin/bash


# Return partitions detected on the system
function rtux_Get_System_Partitions () {
  awk '{print $4}' ${PROC_PARTITIONS_FILE} \
  | sed -e '/name/d' -e '/^$/d' -e '/[1-9]/!d'
}

# Return partitions which have Linux os detector on them
function rtux_Get_Linux_Os_Partitions() {
local TARGET_PARTITIONS=$(rtux_Get_System_Partitions())
local SBIN_GRUB_PARTITIONS=""

for n_partition in ${TARGET_PARTITIONS}; do
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}

  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ; then
    if [[ -e ${TMP_MNT_PARTITION}${LINUX_OS_DETECTOR} ]] ; then
      SBIN_GRUB_PARTITIONS="${SBIN_GRUB_PARTITIONS} ${n_partition}"
    fi
    umount ${TMP_MNT_PARTITION};
  fi
done

echo "${SBIN_GRUB_PARTITIONS}"

}


# Returns Desktop width
function rtux_Get_Desktop_Width () {
  wmctrl -d \
  | head -n 1 \
  | awk '{print $4}' \
  | awk -F 'x' '{print $1}'
} # function rtux_Get_Desktop_Width ()


# Rescatux lib main variables

RESCATUX_URL="http://rescatux.berlios.de"
RESCATUX_IRC_URL="irc://irc.freenode.net/rescatux"
RESC_USER_IRC_PREFIX="resc_user_"

RESCAPP_WIDTH="600"
RESCAPP_HEIGHT="400"
ZENITY_COMMON_OPTIONS="--width=${GRUB_INSTALL_MBR_WIDTH} \
		       --height=${GRUB_INSTALL_MBR_HEIGHT}"

EXIT_STR="Exit"

RUN_STR="Run"

FIREFOX_COMMAND="iceweasel"
GEDIT_COMMAND="gedit"
XCHAT_COMMAND="xchat"
FDISK_COMMAND="/sbin/fdisk"

FIREFOX_WINDOW_STR="Iceweasel"
XCHAT_WINDOW_STR="Xchat"

CODE_STR="Code"
NAME_STR="Name"
DESCRIPTION_STR="Description"
WHICH_PARTITION_STR="Which partition is your main GNU/Linux?"
SELECT_STR="Select"
PARTITION_STR="Partition"
POSITION_STR="Position"
HARDDISK_STR="Hard Disk"
SIZE_STR="Size"

PREPARE_ORDER_HDS_STR="These are detected hard disks. Prepare to order them according to boot order. Press OK to continue."
RIGHT_HD_POSITION_STR="Which is the right position for this hard disk?"
SUCCESS_STR="Success!"
FAILURE_STR="Failure!"



PROC_PARTITIONS_FILE=/proc/partitions

RESCATUX_ROOT_MNT=/mnt/rescatux
LINUX_OS_DETECTOR="/etc/issue"
GRUB_INSTALL_BINARY=grub-install
ETC_ISSUE_PATH="/etc/issue"


TMP_FOLDER="/tmp"



