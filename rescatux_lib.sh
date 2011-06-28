#!/bin/bash

# Given a partition it returns its etc issue content
# Format is modified so that zenity does not complain
function rtux_Get_Etc_Issue_Content() {
  local PARTITION_TO_MOUNT=$1
  local n_partition=${PARTITION_TO_MOUNT}

  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ; then
    if [[ -e ${TMP_MNT_PARTITION}${ETC_ISSUE_PATH} ]] ; then
      echo $(head -n 1 ${TMP_MNT_PARTITION}${ETC_ISSUE_PATH} |\
	sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /-/g' -e 's/\ \ /-/g' -e 's/\n/-/g')
    else
      echo "${NOT_DETECTED_STR}"
    fi
    umount ${TMP_MNT_PARTITION};
  else
    echo "${CANT_MOUNT_STR}"
  fi
} # function rtux_Get_Etc_Issue_Content()

# Return partitions detected on the system
function rtux_Get_System_Partitions () {
  awk '{ if ( ( NR>2 ) && ( $4 ~ "[0-9]$" ) ) {print $4} }' ${PROC_PARTITIONS_FILE}
} # function rtux_Get_System_Partitions ()

# Return partitions which are primary partitions
function rtux_Get_Primary_Partitions() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)

  echo "${TARGET_PARTITIONS}" | awk '$1 ~ "[[:alpha:]][1-4]$" { printf $1 " " }'
} # function rtux_Get_Primary_Partitions ()


# Return partitions which have Linux os detector on them
function rtux_Get_Linux_Os_Partitions() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)
  local SBIN_GRUB_PARTITIONS=""

  for n_partition in ${TARGET_PARTITIONS}; do
    local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
    local TMP_DEV_PARTITION=/dev/${n_partition}
    mkdir --parents ${TMP_MNT_PARTITION}

    if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ;
    then
      if [[ -e ${TMP_MNT_PARTITION}${LINUX_OS_DETECTOR} ]] ; then
        SBIN_GRUB_PARTITIONS="${SBIN_GRUB_PARTITIONS} ${n_partition}"
      fi
      umount ${TMP_MNT_PARTITION};
    fi
  done

  echo "${SBIN_GRUB_PARTITIONS}"
} # function rtux_Get_Linux_Os_Partitions ()

# Return partitions which have Windows os detector on them
function rtux_Get_Windows_Os_Partitions() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)
  local SBIN_GRUB_PARTITIONS=""

  for n_partition in ${TARGET_PARTITIONS}; do
    local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
    local TMP_DEV_PARTITION=/dev/${n_partition}
    mkdir --parents ${TMP_MNT_PARTITION}

    if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ;
    then
      for n_windir in ${TMP_MNT_PARTITION}/* ; do
	  if [ -e ${n_windir}\
/[Ss][Yy][Ss][Tt][Ee][Mm]32\
/[Cc][Oo][Nn][Ff][Ii][Gg]\
/[Ss][Aa][Mm]\
	  ] ; then
	    SBIN_GRUB_PARTITIONS="${SBIN_GRUB_PARTITIONS} ${n_partition}"
	  fi
      done
      umount ${TMP_MNT_PARTITION};
    fi
  done

  echo "${SBIN_GRUB_PARTITIONS}"
} # rtux_Get_Windows_Os_Partitions ()


# Return hard disks detected on the system
function rtux_Get_System_HardDisks () {
  awk '{ if ( ( NR>2 ) && ( $4 ~ "[[:alpha:]]$" ) ) {print $4} }' ${PROC_PARTITIONS_FILE}
} # function rtux_Get_System_HardDisks ()

# Informs the user about an operation that has been successful
# Every parametre is treated as the message to be shown to the user.
function rtux_Message_Success () {
  local text_to_show="$@"
  zenity ${ZENITY_COMMON_OPTIONS} \
    --info \
    --title="${SUCCESS_STR}" \
    --text="${text_to_show}";
} # function rtux_Message_Success ()

# Informs the user about an operation that has been not successful
# Every parametre is treated as the message to be shown to the user.
function rtux_Message_Failure () {
  local text_to_show="$@"
  zenity ${ZENITY_COMMON_OPTIONS} \
    --info \
    --title="${FAILURE_STR}" \
    --text="${text_to_show}";
} # function rtux_Message_Failure ()

# Return hard disk that the user chooses
# Every parametre is treated as the question to be asked to the user.
function rtux_Choose_Hard_Disk () {
  local text_to_ask="$@"
  local n=0
  local HD_LIST_VALUES=""
  local DETECTED_HARD_DISKS=$(rtux_Get_System_HardDisks);
  for n_hard_disk in ${DETECTED_HARD_DISKS}; do
    if [[ ${n} -eq 0 ]] ; then
      local HD_LIST_VALUES="TRUE ${n_hard_disk} `${FDISK_COMMAND} -l \
      | egrep ${n_hard_disk} \
      | egrep 'Disk.*bytes' \
      | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
    else
      local HD_LIST_VALUES="${HD_LIST_VALUES} FALSE ${n_hard_disk} `${FDISK_COMMAND} -l \
      | egrep ${n_hard_disk} \
      | egrep 'Disk.*bytes' \
      | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
    fi
    let n=n+1
  done

  echo $(zenity ${ZENITY_COMMON_OPTIONS}  \
	--list  \
	--text "${text_to_ask}" \
	--radiolist  \
	--column "${SELECT_STR}" \
	--column "${HARDDISK_STR}" \
	--column "${SIZE_STR}" ${HD_LIST_VALUES}); 

} # function rtux_Choose_Hard_Disk ()

# Let the user choose a partition
# It outputs choosen partition
function rtux_Choose_Partition () {
  rtux_Abstract_Choose_Partition $(rtux_Get_System_Partitions)
} # function rtux_Choose_Partition ()

# Let the user choose a partition
# It outputs choosen partition
function rtux_Choose_Primary_Partition () {
  rtux_Abstract_Choose_Partition $(rtux_Get_Primary_Partitions)
} # function rtux_Choose_Primary_Partition ()

# Let the user choose a partition
# Every parametre are the source partitions
# It outputs choosen partition
function rtux_Abstract_Choose_Partition () {
  local n=0
  local LIST_VALUES=""
  local DESC_VALUES=""
  local SBIN_GRUB_PARTITIONS="$@"
  for n_partition in ${SBIN_GRUB_PARTITIONS}; do
    local issue_value=`rtux_Get_Etc_Issue_Content ${n_partition}`
    issue_value=$(echo $issue_value | sed 's/\ /\-/')
    issue_value=$(echo $issue_value | sed 's/ /\-/')
    
    if [[ n -eq 0 ]] ; then
      LIST_VALUES="TRUE ${n_partition} ${issue_value}"
    else
      LIST_VALUES="${LIST_VALUES} FALSE ${n_partition} ${issue_value}"
    fi
  let n=n+1
  done

  echo "$(zenity ${ZENITY_COMMON_OPTIONS}  \
	--list  \
	--text "${WHICH_PARTITION_STR}" \
	--radiolist  \
	--column "${SELECT_STR}" \
	--column "${PARTITION_STR}" \
	--column "${DESCRIPTION_STR}" ${LIST_VALUES})";
} # function rtux_Abstract_Choose_Partition ()

# Let the user choose his main GNU/Linux partition
# It outputs choosen partition
function rtux_Choose_Linux_partition () {
  rtux_Abstract_Choose_Partition $(rtux_Get_Linux_Os_Partitions)
} # function rtux_Choose_Linux_partition ()

# Let the user choose his main Windows partition
# It outputs choosen partition
function rtux_Choose_Windows_partition () {
  rtux_Abstract_Choose_Partition $(rtux_Get_Windows_Os_Partitions)
} # function rtux_Choose_Windows_partition ()

# Let the user rename hard disks if they want to
# Returns the new target partitions
function rtux_Choose_HardDisk_Renaming () {
  local DETECTED_HARD_DISKS=$(rtux_Get_System_HardDisks)

  mkdir /dev/new

  # Let's loop on detected hard disks so that user can rename them
  for n_hard_disk in ${DETECTED_HARD_DISKS} ; do

    local new_hard_disk_name=$(zenity ${ZENITY_COMMON_OPTIONS}  \
			  --entry --title="Rename hard disk if needed" \
			  --text="Detected: ${n_hard_disk}" \
			  --entry-text="${n_hard_disk}");

    ln -s /dev/${n_hard_disk} /dev/new/${new_hard_disk_name}
    for n_partition in /dev/* ; do
      local actual_partition=$(echo "${n_partition}" | sed 's%/dev/%%g')
      local test_partition=$(echo ${actual_partition} | grep ${n_hard_disk})
      local partition_number=$(echo ${test_partition} | sed "s%${n_hard_disk}%%g")
      if [[ "${test_partition}x" != "x" ]] ; then
	  ln -s /dev/${n_hard_disk}${partition_number} \
	    /dev/new/${new_hard_disk_name}${partition_number}
      fi
    done
  done


  # We are going to redefine TARGET_PARTITIONS with user choosen hard disks
  local TARGET_PARTITIONS=""
  # Let's move some partitions
  for n_partition in /dev/new/* ; do
    local new_partition=$(echo $n_partition | sed 's%/dev/new/%%g')
    local old_partition=$(readlink ${n_partition})
    mv $old_partition /dev/${new_partition}
    TARGET_PARTITIONS="${TARGET_PARTITIONS} ${new_partition}"

  done
  echo ${TARGET_PARTITIONS}
} # rtux_Choose_HardDisk_Renaming ()


# Returns Desktop width
function rtux_Get_Desktop_Width () {
  wmctrl -d \
  | head -n 1 \
  | awk '{print $4}' \
  | awk -F 'x' '{print $1}'
} # function rtux_Get_Desktop_Width ()

# DEVICE_MAP_RESCATUX_STR has to be defined
# DEVICE_MAP_BACKUP_STR has to be defined
# Actually they are defined because they come with rescatux lib
# Parametres: Main command line that has to be run.
# Outputs the file to be run as an script inside chroot
# It swaps current device.map with a temporal one
function rtux_File_Chroot_Script_Device_Map() {
local command_line_to_run="$@"
  cat << EOF > ${TMP_MNT_PARTITION}${TMP_SCRIPT}
    mount -a
    # Backup current device.map file (inside chroot) - TODO - BEGIN
    cp /boot/grub/device.map /boot/grub/${DEVICE_MAP_BACKUP_STR}
    # Backup current device.map file (inside chroot) - TODO - END

    # Overwrite current device.map file with temporal device.map (inside chroot) - TODO - BEGIN
    cp /${DEVICE_MAP_RESCATUX_STR} /boot/grub/device.map
    # Overwrite current device.map file with temporal device.map (inside chroot) - TODO - END

    ${command_line_to_run}
    UPDATE_GRUB_OUTPUT=\$?

    # Restore current device.map file - BEGIN
    cp /boot/grub/${DEVICE_MAP_BACKUP_STR} /boot/grub/device.map
    # Restore current device.map file - END
    # Delete temporal and backup device.map files- TODO - BEGIN
    rm /boot/grub/${DEVICE_MAP_BACKUP_STR}
    rm /${DEVICE_MAP_RESCATUX_STR}
    # Delete temporal and backup device.map files- TODO - END
    umount -a
    exit \${UPDATE_GRUB_OUTPUT}
EOF
}

# 1 parametre = Selected hard disk
# User is asked to select hard disk
# position
function rtux_Choose_Hard_Disk_Position() {

  local SELECTED_HARD_DISK="$1"
  local DETECTED_HARD_DISKS="$(rtux_Get_System_HardDisks)";

  # LOOP - Show hard disk and ask position - TODO - BEGIN
  local HD_LIST_VALUES=""
  local m=1
  for n_hard_disk in ${DETECTED_HARD_DISKS}; do
			      
      if [[ m -eq 1 ]] ; then
	HD_LIST_VALUES="TRUE ${m} ${SELECTED_HARD_DISK} \
	  `/sbin/fdisk -l /dev/${SELECTED_HARD_DISK} \
		  | egrep 'Disk.*bytes' \
		  | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
      else
	HD_LIST_VALUES="${HD_LIST_VALUES} FALSE ${m} ${SELECTED_HARD_DISK} \
	`/sbin/fdisk -l /dev/${SELECTED_HARD_DISK} \
		  | egrep 'Disk.*bytes' \
		  | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
      fi
      let m=m+1
  done

    # Ask position - BEGIN
    local SELECTED_POSITION=$(zenity ${ZENITY_COMMON_OPTIONS} \
	  --list  \
	  --text "${RIGHT_HD_POSITION_STR}" \
	  --radiolist  \
	  --column "${SELECT_STR}" \
	  --column "${POSITION_STR}" \
	  --column "${HARDDISK_STR}" \
	  --column "${SIZE_STR}" \
	  ${HD_LIST_VALUES}); 

    # Ask position - END
    
    echo "${SELECTED_POSITION}"

} # rtux_Choose_Hard_Disk_Position()


# User is asked to order the hard disks
#  so that they have their actual order
# Outputs device.map file with ordered devices
function rtux_File_Reordered_Device_Map() {

  local DETECTED_HARD_DISKS=$(rtux_Get_System_HardDisks);
  rtux_Choose_Hard_Disk ${PREPARE_ORDER_HDS_STR} > /dev/null

  # LOOP - Show hard disk and ask position - TODO - BEGIN
  local n=1
  local HD_LIST_VALUES=""
  for n_hard_disk in ${DETECTED_HARD_DISKS}; do
    m=1
    for m_hard_disk in ${DETECTED_HARD_DISKS}; do			      
      if [[ m -eq 1 ]] ; then
	HD_LIST_VALUES="TRUE ${m} ${n_hard_disk} \
	  `/sbin/fdisk -l /dev/${n_hard_disk} \
		  | egrep 'Disk.*bytes' \
		  | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
      else
	HD_LIST_VALUES="${HD_LIST_VALUES} FALSE ${m} ${n_hard_disk} \
	`/sbin/fdisk -l /dev/${n_hard_disk} \
		  | egrep 'Disk.*bytes' \
		  | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
      fi
      let m=m+1
    done

    # Ask position - BEGIN
    local SELECTED_POSITION=$(zenity ${ZENITY_COMMON_OPTIONS} \
	  --list  \
	  --text "${RIGHT_HD_POSITION_STR}" \
	  --radiolist  \
	  --column "${SELECT_STR}" \
	  --column "${POSITION_STR}" \
	  --column "${HARDDISK_STR}" \
	  --column "${SIZE_STR}" \
	  ${HD_LIST_VALUES}); 

    # Ask position - END
    # Generate temporal file with order - TODO - BEGIN
    echo -e -n "${SELECTED_POSITION} (hd$(( ${SELECTED_POSITION} - 1 ))) /dev/${n_hard_disk}\n"
    # Generate temporal file with order - TODO - END
    let n=n+1
  done | sort | awk '{printf("%s\t%s\n",$2,$3);}' 

} # rtux_File_Reordered_Device_Map()


# Rescatux lib main variables

RESCATUX_URL="http://rescatux.berlios.de"
RESCATUX_IRC_URL="irc://irc.freenode.net/rescatux"
RESCATUX_PASTEBIN_URL="http://paste.debian.net"
RESC_USER_IRC_PREFIX="resc_user_"

RESCAPP_WIDTH="600"
RESCAPP_HEIGHT="400"
ZENITY_COMMON_OPTIONS="--width=${RESCAPP_WIDTH} \
		       --height=${RESCAPP_HEIGHT}"

EXIT_STR="Exit"

RUN_STR="Run"

FIREFOX_COMMAND="iceweasel"
GEDIT_COMMAND="leafpad"
XCHAT_COMMAND="xchat"
FDISK_COMMAND="/sbin/fdisk"
FILEMANAGER_COMMAND="pcmanfm"

FIREFOX_WINDOW_STR="Iceweasel"
XCHAT_WINDOW_STR="Xchat"

CODE_STR="Code"
NAME_STR="Name"
DESCRIPTION_STR="Description"
WHICH_PARTITION_STR="Which partition?"
SELECT_STR="Select"
PARTITION_STR="Partition"
POSITION_STR="Position"
HARDDISK_STR="Hard Disk"
SIZE_STR="Size"

PREPARE_ORDER_HDS_STR="These are detected hard disks. Prepare to order them according to boot order. Press OK to continue."
RIGHT_HD_POSITION_STR="Which is the right position for this hard disk?"
SUCCESS_STR="Success!"
FAILURE_STR="Failure!"
NOT_DETECTED_STR="Not detected"
CANT_MOUNT_STR="Cannot mount"
RUNNING_STR="Running process... Please wait till finish message appears."


PROC_PARTITIONS_FILE=/proc/partitions

RESCATUX_ROOT_MNT=/mnt/rescatux
LINUX_OS_DETECTOR="/etc/issue"
GRUB_INSTALL_BINARY=grub-install
ETC_ISSUE_PATH="/etc/issue"

TMP_FOLDER="/tmp"

DEVICE_MAP_RESCATUX_STR="device.map.rescatux"
DEVICE_MAP_BACKUP_STR="device.map.rescatux.backup"






