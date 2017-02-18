#!/bin/bash
# Rescapp Rescatux main library: rescatux_lib
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

# Given a partition it returns its etc issue content
# Format is modified so that zenity does not complain
function rtux_Get_Etc_Issue_Content_payload() {
  local PARTITION_TO_MOUNT=$1
  local n_partition=${PARTITION_TO_MOUNT}

  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}

  if rtux_UEFI_Check_Is_EFI_System_Partition ${n_partition} ; then
    echo "${EFI_SYSTEM_STR}"
  else
    mkdir --parents ${TMP_MNT_PARTITION}
    if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ; then
      if [[ -e ${TMP_MNT_PARTITION}${ETC_ISSUE_PATH} ]] ; then
        echo $(head -n 1 ${TMP_MNT_PARTITION}${ETC_ISSUE_PATH} |\
          sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g')
      else
        echo "${NOT_DETECTED_STR}" |\
          sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g'
      fi
      umount ${TMP_MNT_PARTITION};
    else
      echo "${CANT_MOUNT_STR}" |\
        sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g'
    fi
  fi
} # function rtux_Get_Etc_Issue_Content_payload()

# Given a partition it returns its filesystem type
# Format is modified so that zenity does not complain
function rtux_Get_Partition_Filesystem_payload() {
  local PARTITION_TO_MOUNT=$1
  local n_partition=${PARTITION_TO_MOUNT}

  local TMP_DEV_PARTITION=/dev/${n_partition}
  local partition_filesystem

  partition_filesystem="$(${RESCATUX_PATH}show_partition_filesystem.py ${TMP_DEV_PARTITION})"
  SHOW_PARTITION_FILESYSTEM_EXIT_VALUE=$?
  if [ $SHOW_PARTITION_FILESYSTEM_EXIT_VALUE -eq 0 ] ; then
    echo "${partition_filesystem}" |\
        sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g'
  else
    echo "${NO_FILESYSTEM_STR}"
  fi

} # function rtux_Get_Partition_Filesystem_payload()

# Given a partition it returns its flags
# Format is modified so that zenity does not complain
function rtux_Get_Partition_Flags_payload() {
  local PARTITION_TO_MOUNT=$1
  local n_partition=${PARTITION_TO_MOUNT}

  local TMP_DEV_PARTITION=/dev/${n_partition}
  local partition_flags

  partition_flags="$(${RESCATUX_PATH}show_partition_flags.py ${TMP_DEV_PARTITION})"
  SHOW_PARTITION_FLAGS_EXIT_VALUE=$?
  if [ $SHOW_PARTITION_FLAGS_EXIT_VALUE -eq 0 ] ; then
    echo "${partition_flags}" |\
        sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g'
  else
    echo "${NO_FLAGS_STR}"
  fi

} # function rtux_Get_Partition_Flags_payload()

# Given a partition it returns its os-prober long name
# Format is modified so that zenity does not complain
function rtux_Get_Partition_Osprober_Longname_payload() {
  local PARTITION_TO_MOUNT=$1
  local n_partition=${PARTITION_TO_MOUNT}

  local TMP_DEV_PARTITION=/dev/${n_partition}
  local partition_osprober_longname
  os-prober | grep -E '^'${TMP_DEV_PARTITION}'[@:]' | awk -F ':' '{print $2}' > /dev/null 2>&1
  SHOW_PARTITION_OSPROBER_LONGNAME_EXIT_VALUE=${PIPESTATUS[1]} # TODO: Improve error handling when os-prober fails
  if [ ${SHOW_PARTITION_OSPROBER_LONGNAME_EXIT_VALUE} -eq 0 ] ; then
    partition_osprober_longname="$(os-prober | grep -E '^'${TMP_DEV_PARTITION}'[@:]' | awk -F ':' '{print $2}')"
    echo "${partition_osprober_longname}" |\
        sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g'
  else
    echo "${NO_OSPROBER_LONGNAME_STR}"
  fi

} # function rtux_Get_Partition_Osprober_Longname_payload()

function rtux_Get_Etc_Issue_Content() {
  GET_ETC_ISSUE_CONTENT_RUNNING_STR="Parsing /etc/issue file."
  rtux_Run_Show_Progress "${GET_ETC_ISSUE_CONTENT_RUNNING_STR}" rtux_Get_Etc_Issue_Content_payload "$@"
} # function rtux_Get_Etc_Issue_Content()

function rtux_Get_Partition_Filesystem() {
  GET_PARTITION_FILESYSTEM_RUNNING_STR="Getting partition filesystem."
  rtux_Run_Show_Progress "${GET_PARTITION_FILESYSTEM_RUNNING_STR}" rtux_Get_Partition_Filesystem_payload "$@"
} # function rtux_Get_Partition_Filesystem()

function rtux_Get_Partition_Flags() {
  GET_PARTITION_FLAGS_RUNNING_STR="Getting partition flags."
  rtux_Run_Show_Progress "${GET_PARTITION_FLAGS_RUNNING_STR}" rtux_Get_Partition_Flags_payload "$@"
} # function rtux_Get_Partition_Flags()

function rtux_Get_Partition_Osprober_Longname() {
  GET_PARTITION_OSPROBER_LONGNAME_RUNNING_STR="Getting os-prober long name."
  rtux_Run_Show_Progress "${GET_PARTITION_OSPROBER_LONGNAME_RUNNING_STR}" rtux_Get_Partition_Osprober_Longname_payload "$@"
} # function rtux_Get_Partition_Osprober_Longname()

# Return partitions detected on the system
function rtux_Get_System_Partitions_payload () {
  awk '{ if ( ( NR>2 ) && ( $4 ~ "[0-9]$" ) ) {print $4} }' ${PROC_PARTITIONS_FILE}
} # function rtux_Get_System_Partitions_payload ()

# Return partitions detected on the system
function rtux_Get_System_Partitions () {
  GET_SYSTEM_PARTITIONS_RUNNING_STR="Getting System partitions."
  rtux_Run_Show_Progress "${GET_SYSTEM_PARTITIONS_RUNNING_STR}" rtux_Get_System_Partitions_payload "$@"
} # function rtux_Get_System_Partitions ()

# Return partitions which are primary partitions
function rtux_Get_Primary_Partitions_payload() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)

  echo "${TARGET_PARTITIONS}" | awk '$1 ~ "[[:alpha:]][1-4]$" { printf $1 " " }'
} # function rtux_Get_Primary_Partitions_payload ()

# Return partitions which are primary partitions
function rtux_Get_Primary_Partitions() {
  GET_PRIMARY_PARTITIONS_RUNNING_STR="Getting Primary partitions."
  rtux_Run_Show_Progress "${GET_PRIMARY_PARTITIONS_RUNNING_STR}" rtux_Get_Primary_Partitions_payload "$@"
} # function rtux_Get_Primary_Partitions ()

# Return partitions which have Linux os detector on them
function rtux_Get_Linux_Os_Partitions_payload() {
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
} # function rtux_Get_Linux_Os_Partitions_payload ()

function rtux_Get_Linux_Os_Partitions() {
  GET_LINUX_OS_PARTITIONS_RUNNING_STR="Getting GNU/Linux OS partitions."
  rtux_Run_Show_Progress "${GET_LINUX_OS_PARTITIONS_RUNNING_STR}" rtux_Get_Linux_Os_Partitions_payload "$@"
} # function rtux_Get_Linux_Os_Partitions ()

# Return partitions which have Windows os detector on them
function rtux_Get_Windows_Os_Partitions_payload() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)
  local SBIN_GRUB_PARTITIONS=""

  for n_partition in ${TARGET_PARTITIONS}; do
    local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
    local TMP_DEV_PARTITION=/dev/${n_partition}
    mkdir --parents ${TMP_MNT_PARTITION}

    if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ;
    then
      for n_windir in ${TMP_MNT_PARTITION}/* ; do
	  if [ -e "${n_windir}"\
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
} # rtux_Get_Windows_Os_Partitions_payload ()

# Return partitions which have Windows os detector on them
function rtux_Get_Windows_Os_Partitions() {
  GET_WINDOWS_OS_PARTITIONS_RUNNING_STR="Getting Microsoft Windows OS partitions."
  rtux_Run_Show_Progress "${GET_WINDOWS_OS_PARTITIONS_RUNNING_STR}" rtux_Get_Windows_Os_Partitions_payload "$@"
} # rtux_Get_Windows_Os_Partitions ()

# Return hard disks detected on the system
function rtux_Get_System_HardDisks_payload () {
  awk '{ if ( ( NR>2 ) && ( $4 ~ "[[:alpha:]]$" ) ) {print $4} }' ${PROC_PARTITIONS_FILE}
} # function rtux_Get_System_HardDisks_payload ()

# Return hard disks detected on the system
function rtux_Get_System_HardDisks () {
  GET_SYSTEM_HARDDISKS_RUNNING_STR="Getting system hard disks."
  rtux_Run_Show_Progress "${GET_SYSTEM_HARDDISKS_RUNNING_STR}" rtux_Get_System_HardDisks_payload "$@"
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

# Informs the user about anything
# Every parametre is treated as the message to be shown to the user.
function rtux_Message_Info () {
  local text_to_show="$@"
  zenity ${ZENITY_COMMON_OPTIONS} \
    --info \
    --title="${INFO_STR}" \
    --text="${text_to_show}";
} # function rtux_Message_Info ()

# Informs the user about an operation that has been not successful
# Every parametre is treated as the message to be shown to the user.
function rtux_Message_Failure () {
  local text_to_show="$@"
  zenity ${ZENITY_COMMON_OPTIONS} \
    --error \
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
      | grep -E "^Disk /dev/${n_hard_disk}.*bytes" \
      | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
    else
      local HD_LIST_VALUES="${HD_LIST_VALUES} FALSE ${n_hard_disk} `${FDISK_COMMAND} -l \
      | grep -E "^Disk /dev/${n_hard_disk}.*bytes" \
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

    local partition_filesystem="$(rtux_Get_Partition_Filesystem ${n_partition})"
    partition_filesystem=$(echo $partition_filesystem | sed 's/\ /\-/')
    partition_filesystem=$(echo $partition_filesystem | sed 's/ /\-/')

    local partition_flags="$(rtux_Get_Partition_Flags ${n_partition})"
    partition_flags=$(echo $partition_flags | sed 's/\ /\-/')
    partition_flags=$(echo $partition_flags | sed 's/ /\-/')

    local partition_osprober_longname="$(rtux_Get_Partition_Osprober_Longname ${n_partition})"
    partition_osprober_longname=$(echo $partition_osprober_longname | sed 's/\ /\-/')
    partition_osprober_longname=$(echo $partition_osprober_longname | sed 's/ /\-/')
    
    if [[ n -eq 0 ]] ; then
      LIST_VALUES="TRUE ${n_partition} ${issue_value} ${partition_filesystem} ${partition_flags} ${partition_osprober_longname}"
    else
      LIST_VALUES="${LIST_VALUES} FALSE ${n_partition} ${issue_value} ${partition_filesystem} ${partition_flags} ${partition_osprober_longname}"
    fi
  let n=n+1
  done

  echo "$(zenity ${ZENITY_COMMON_OPTIONS}  \
	--list  \
	--text "${WHICH_PARTITION_STR}" \
	--radiolist  \
	--column "${SELECT_STR}" \
	--column "${PARTITION_STR}" \
	--column "${DESCRIPTION_STR}" \
	--column "${FILESYSTEM_STR}" \
	--column "${FLAGS_STR}" \
	--column "${OSPROBER_LONGNAME_STR}" \
	${LIST_VALUES} \
	)";
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
    set -x -v
    BOOT_GRUB_DIR="/boot/grub"
    if [ -d "/boot/grub2" ] ; then
      BOOT_GRUB_DIR="/boot/grub2"
    fi
    # Backup current device.map file (inside chroot) - TODO - BEGIN
    cp \${BOOT_GRUB_DIR}/device.map \${BOOT_GRUB_DIR}/${DEVICE_MAP_BACKUP_STR}
    # Backup current device.map file (inside chroot) - TODO - END

    # Overwrite current device.map file with temporal device.map (inside chroot) - TODO - BEGIN
    cp /${DEVICE_MAP_RESCATUX_STR} \${BOOT_GRUB_DIR}/device.map
    # Overwrite current device.map file with temporal device.map (inside chroot) - TODO - END

    ${command_line_to_run}
    UPDATE_GRUB_OUTPUT=\$?

    # Restore current device.map file - BEGIN
    cp \${BOOT_GRUB_DIR}/${DEVICE_MAP_BACKUP_STR} \${BOOT_GRUB_DIR}/device.map
    # Restore current device.map file - END
    # Delete temporal and backup device.map files- TODO - BEGIN
    rm \${BOOT_GRUB_DIR}/${DEVICE_MAP_BACKUP_STR}
    rm /${DEVICE_MAP_RESCATUX_STR}
    # Delete temporal and backup device.map files- TODO - END
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
function rtux_File_Reordered_Device_Map_payload() {


  local DETECTED_HARD_DISKS=$(rtux_Get_System_HardDisks);
  local COLUMN_NUMBER=2 # Determine Hard disk column and Size column
  local HARD_DISK_NUMBER=0
  for n_hard_disk in ${DETECTED_HARD_DISKS}; do
    let HARD_DISK_NUMBER=HARD_DISK_NUMBER+1
  done

  if [ ${HARD_DISK_NUMBER} -gt 1 ] ; then
    ARGS_ARRAY_INDEX=0
    ARGS_ARRAY[ARGS_ARRAY_INDEX]=${COLUMN_NUMBER}
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="${ORDER_HDS_WTITLE}"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="${ORDER_HDS_STR}"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="Hard disk"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="Size"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    for n_hard_disk in ${DETECTED_HARD_DISKS}; do
      ARGS_ARRAY[ARGS_ARRAY_INDEX]="${n_hard_disk}"
      let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
      ARGS_ARRAY[ARGS_ARRAY_INDEX]="`/sbin/fdisk -l /dev/${n_hard_disk} \
		    | egrep 'Disk.*bytes' \
		    | awk '{ sub(/,/,"");  print $3 "-" $4 }'`"
      let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    done
    DESIRED_ORDER=`${RESCATUX_PATH}order.py "${ARGS_ARRAY[@]}"`
  else
    DESIRED_ORDER="${DETECTED_HARD_DISKS}"
  fi

  local n=0
  for n_hard_disk in ${DESIRED_ORDER} ; do
    echo -e -n "(hd${n}) /dev/${n_hard_disk}\n"
    let n=n+1
  done

} # rtux_File_Reordered_Device_Map_payload()

function rtux_File_Reordered_Device_Map() {
  GET_FILE_REORDERED_DEVICE_MAP_RUNNING_STR="Reordering device.map file."
  rtux_Run_Show_Progress "${GET_FILE_REORDERED_DEVICE_MAP_RUNNING_STR}" rtux_File_Reordered_Device_Map_payload "$@"
} # rtux_File_Reordered_Device_Map()

# 1 parametre = Passwd filename
# Return users list from passwd
function rtux_User_List_payload() {
  PASSWD_FILENAME="$1"
  awk -F : '{print $1}' "${PASSWD_FILENAME}" | tr '\n' ' '
} # rtux_User_List_payload()

function rtux_User_List() {
  USER_LIST_RUNNING_STR="Getting users from passwd file."
  rtux_Run_Show_Progress "${USER_LIST_RUNNING_STR}" rtux_User_List_payload "$@"
} # rtux_User_List()

# Let the user choose an user
# Every parametre are the users
# It outputs choosen user
function rtux_Choose_User () {
  local n=0
  local LIST_VALUES=""
  local DESC_VALUES=""
  local USERS_LIST="$@"
  for n_user in ${USERS_LIST}; do
    if [[ n -eq 0 ]] ; then
      LIST_VALUES="TRUE ${n_user}"
    else
      LIST_VALUES="${LIST_VALUES} FALSE ${n_user}"
    fi
  let n=n+1
  done

  echo "$(zenity ${ZENITY_COMMON_OPTIONS}  \
	--list  \
	--text "${WHICH_USER_STR}" \
	--radiolist  \
	--column "${SELECT_STR}" \
	--column "${USER_STR}" \
	${LIST_VALUES})";
} # function rtux_Choose_User ()

# 1 parametre = User to change password
# User is asked to write temp password
# Outputs choosen password
function rtux_Enter_Pass() {

  local USER="$1"

    zenity ${ZENITY_COMMON_OPTIONS} \
	  --entry  \
	  --text "${ENTER_PASS_STR} (${USER})" \
	  --hide-text

} # rtux_Choose_Hard_Disk_Position()

# 1 parametre = Temporal mount point
# Return temporal fstab path
function rtux_make_tmp_fstab_payload() {

  local TMP_MNT_PARTITION="$1"
  local ORIGINAL_FSTAB="${TMP_MNT_PARTITION}/etc/fstab"
  local TMP_FSTAB="${TMP_FOLDER}/tmp-rescatux-fstab-$$"
  cat "${ORIGINAL_FSTAB}" |\
  grep -E -v '^#' |\
  grep -E -v '^[[:space:]]*$' |\
  awk -v mount_dir=${TMP_MNT_PARTITION} '{
    if ($2 != "none" && $2 == "/")
      print $1 " " mount_dir " " $3 " " $4 " " $5 " " $6 ;
    else if ($2 != "none")
           print $1 " "mount_dir $2 " " $3 " " $4 " " $5 " " $6 ;
    else
      print $1 " " $2 " " $3 " " $4 " " $5 " " $6;
  }
  ' \
  > "${TMP_FSTAB}"

  echo "${TMP_FSTAB}";

} # rtux_make_tmp_fstab_payload()

function rtux_make_tmp_fstab() {
  MAKE_TMP_FSTAB_RUNNING_STR="Making temporal fstab file."
  rtux_Run_Show_Progress "${MAKE_TMP_FSTAB_RUNNING_STR}" rtux_make_tmp_fstab_payload "$@"
} # rtux_make_tmp_fstab()

# 1 parametre = Selected partition
# 2 parametre = SAM file
function rtux_backup_windows_config_payload () {

  local SELECTED_PARTITION="$1"
  local SAM_FILE="$2"

  # Mount the partition
  local n_partition=${SELECTED_PARTITION}
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then

      PRE_RESCATUX_STR="PRE_RESCATUX"
      CURRENT_SECOND_STR="$(date +%Y-%m-%d-%H-%M-%S)"
      SAM_DIR="$(dirname ${SAM_FILE})"
      cp -r "${SAM_DIR}" "${SAM_DIR}_${PRE_RESCATUX_STR}_${CURRENT_SECOND_STR}"

      # Umount the partition

      umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok


}

function rtux_backup_windows_config () {
  BACKUP_WINDOWS_CONFIG_RUNNING_STR="Performing backup of Windows registry files."
  rtux_Run_Show_Progress "${BACKUP_WINDOWS_CONFIG_RUNNING_STR}" rtux_backup_windows_config_payload "$@"
}

# TODO: FETCH WIDTH AND HEIGHT FROM COMMAND LINE OR SO
# Return Windows SAM user that the user chooses
# Every parametre is treated as the question to be asked to the user.
function rtux_Choose_Sam_User () {
  local text_to_ask="$@"

  local SAM_LIST_VALUES=()
  local SAM_LIST_VALUE_N=0
  local sam_line_count=0
  while [ ! ${sam_line_count} -eq ${sam_line_total} ] ; do
    if [[ ${sam_line_count} -eq 0 ]] ; then
      SAM_LIST_VALUES[${SAM_LIST_VALUE_N}]="TRUE"
    else
      SAM_LIST_VALUES[${SAM_LIST_VALUE_N}]="FALSE"
    fi
      SAM_LIST_VALUE_N=$((SAM_LIST_VALUE_N+1))
      SAM_LIST_VALUES[${SAM_LIST_VALUE_N}]=$(echo "${SAM_USERS[${sam_line_count}]}" | awk -F ':' '{print $1}')
      SAM_LIST_VALUE_N=$((SAM_LIST_VALUE_N+1))
      SAM_LIST_VALUES[${SAM_LIST_VALUE_N}]=$(echo "${SAM_USERS[${sam_line_count}]}" | awk -F ':' '{print $2}')
      SAM_LIST_VALUE_N=$((SAM_LIST_VALUE_N+1))
      sam_line_count=$((sam_line_count+1))
  done

  echo $(zenity ${ZENITY_COMMON_OPTIONS}  \
	--list  \
	--text "${text_to_ask}" \
	--radiolist  \
	--column "${SELECT_STR}" \
	--column "${SELECT_STR}" \
	--column "${SAM_USER_STR}" \
	"${SAM_LIST_VALUES[@]}");

} # rtux_Choose_Sam_User ()

# Reset windows password payload
# 1 parametre = Selected partition
# 2 parametre = SAM file
# 3 parametre = Choosen user
function rtux_winpass_reset_payload () {

  local SELECTED_PARTITION="$1"
  local SAM_FILE="$2"
  local CHOOSEN_USER="$3"

  local EXIT_VALUE=1 # Error by default
  # Mount the partition
  local n_partition=${SELECTED_PARTITION}
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
  # Run chntpw -L sam-file security-file
	sampasswd -E -r -u "0x${CHOOSEN_USER}" ${SAM_FILE};
	EXIT_VALUE=$?
  # Umount the partition

    umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok

  return ${EXIT_VALUE};

} # rtux_winpass_reset_payload ()

# Reset windows password
# 1 parametre = Selected partition
function rtux_winpass_reset () {

  local SELECTED_PARTITION="$1"
  WINPASS_RESET_RUNNING_STR="Resetting Windows password."
  rtux_Get_Sam_Users ${SELECTED_PARTITION}
  # Backup of the files in a temporal folder
  rtux_backup_windows_config ${SELECTED_PARTITION} "${SAM_FILE}"
  # Ask the user which password to reset
  CHOOSEN_USER=$(rtux_Choose_Sam_User \
    "Choose Windows user to reset its password")
  local PAYLOAD_EXIT_VALUE=1;
  rtux_Run_Show_Progress "${WINPASS_RESET_RUNNING_STR}" rtux_winpass_reset_payload ${SELECTED_PARTITION} ${SAM_FILE} ${CHOOSEN_USER};
  PAYLOAD_EXIT_VALUE=$?
  return ${PAYLOAD_EXIT_VALUE};

} # rtux_winpass_reset ()

# Promote windows user payload
# 1 parametre = Selected partition
# 2 parametre = SAM file
# 3 parametre = Choosen user
function rtux_winpromote_payload () {

  local SELECTED_PARTITION="$1"
  local SAM_FILE="$2"
  local CHOOSEN_USER="$3"

  local EXIT_VALUE=1 # Error by default

  # Mount the partition
  local n_partition=${SELECTED_PARTITION}
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
  local WINDOWS_ADMIN_GROUP_HEX='0x220'
  local WINDOWS_USERS_GROUP_HEX='0x221'
  local WINDOWS_GUESTS_GROUP_HEX='0x222'
  # Comment from chntpw.c file
  # Will add the user to the administrator group (0x220)
  # and to the users group (0x221). That should usually be
  # what is needed to log in and get administrator rights.
  # Also, remove the user from the guest group (0x222), since
  # it may forbid logins.

  # Run chntpw -L sam-file security-file
	samusrgrp -E -a -u "0x${CHOOSEN_USER}" -g ${WINDOWS_ADMIN_GROUP_HEX} ${SAM_FILE};
	EXIT_VALUE=$?
	samusrgrp -E -a -u "0x${CHOOSEN_USER}" -g ${WINDOWS_USERS_GROUP_HEX} ${SAM_FILE};
	samusrgrp -E -r -u "0x${CHOOSEN_USER}" -g ${WINDOWS_GUESTS_GROUP_HEX} ${SAM_FILE};
  # Umount the partition

    umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok

  return ${EXIT_VALUE};

} # function rtux_winpromote_payload ()

# Promote windows user
# 1 parametre = Selected partition
function rtux_winpromote () {
  WINPROMOTE_RUNNING_STR="Promoting Windows user to Admin"

  local SELECTED_PARTITION="$1"
  rtux_Get_Sam_Users ${SELECTED_PARTITION}
  # Backup of the files in a temporal folder
  rtux_backup_windows_config ${SELECTED_PARTITION} "${SAM_FILE}"
  # Ask the user which password to reset
  CHOOSEN_USER=$(rtux_Choose_Sam_User \
    "Choose Windows user to promote to Admin")

  local PAYLOAD_EXIT_VALUE=1;
  rtux_Run_Show_Progress "${WINPROMOTE_RUNNING_STR}" rtux_winpromote_payload ${SELECTED_PARTITION} ${SAM_FILE} ${CHOOSEN_USER};
  PAYLOAD_EXIT_VALUE=$?
  return ${PAYLOAD_EXIT_VALUE};

} # function rtux_winpromote ()

# Unlock windows user payload
# 1 parametre = Selected partition
# 2 parametre = SAM file
# 3 parametre = Choosen user
function rtux_winunlock_payload () {

  local SELECTED_PARTITION="$1"
  local SAM_FILE="$2"
  local CHOOSEN_USER="$3"

  local EXIT_VALUE=1 # Error by default

  # Mount the partition
  local n_partition=${SELECTED_PARTITION}
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
  # Run chntpw -L sam-file security-file
	samunlock -E -U -u "0x${CHOOSEN_USER}" ${SAM_FILE};
	EXIT_VALUE=$?
  # Umount the partition

    umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok

  return ${EXIT_VALUE};

} # function rtux_winunlock ()

# Unlock windows user
# 1 parametre = Selected partition
function rtux_winunlock () {
  WINUNLOCK_RUNNING_STR="Unlocking Windows user"

  local SELECTED_PARTITION="$1"
  rtux_Get_Sam_Users ${SELECTED_PARTITION}
  # Backup of the files in a temporal folder
  rtux_backup_windows_config ${SELECTED_PARTITION} "${SAM_FILE}"
  # Ask the user which password to reset
  CHOOSEN_USER=$(rtux_Choose_Sam_User \
    "Choose Windows user to unlock")

  local PAYLOAD_EXIT_VALUE=1;
  rtux_Run_Show_Progress "${WINUNLOCK_RUNNING_STR}" rtux_winunlock_payload ${SELECTED_PARTITION} ${SAM_FILE} ${CHOOSEN_USER};
  PAYLOAD_EXIT_VALUE=$?
  return ${PAYLOAD_EXIT_VALUE};

} # function rtux_winunlock ()

# Get SAM Users
# 1 parametre = Selected partition
# It sets global variable SAM_USERS
# It sets global variable SAM_FILE
# It sets global variable sam_line_total
function rtux_Get_Sam_Users () {

  local EXIT_VALUE=1 # Error by default
  local SELECTED_PARTITION="$1"
  local SAM_PIPE="/tmp/sampipe"


  # Mount the partition
  local n_partition=${SELECTED_PARTITION}
  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
  # Find the exact name for sam file
      for n_windir in ${TMP_MNT_PARTITION}/* ; do
	if [ -e "${n_windir}"\
/[Ss][Yy][Ss][Tt][Ee][Mm]32\
/[Cc][Oo][Nn][Ff][Ii][Gg]\
/[Ss][Aa][Mm]\
	] ; then
	  SAM_FILE="${n_windir}"\
/[Ss][Yy][Ss][Tt][Ee][Mm]32\
/[Cc][Oo][Nn][Ff][Ii][Gg]\
/[Ss][Aa][Mm]
	fi

      done
  # Define SAM_USERS as a bash array
      SAM_USERS=()
  # Obtain users from SAM file
      sam_line_count=0
      mkfifo "${SAM_PIPE}"
	  sampasswd -l ${SAM_FILE} \
	  > "${SAM_PIPE}" &
      while read -r sam_line ; do
	SAM_USERS[${sam_line_count}]="${sam_line}"
      sam_line_count=$((sam_line_count+1))
      done < "${SAM_PIPE}"
      sam_line_total=${sam_line_count}
      rm "${SAM_PIPE}"

    umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok

}

# Reorder hard disks according to BIOS hard disk order
# 1 parametre = Selected partition
# While it is being run user is shown the hard disks
# and it is asked to order them
# Returns filepath where the temporary rescatux's device.map is saved.
function rtux_Order_Hard_Disks () {
# TODO: Extract last user interaction (Success/Failure)
# So that this function returns being successful or not

  DEVICE_MAP_RESCATUX_FILE_TMP_PATH="/tmp/device_map_rescatux_$$"
  rtux_File_Reordered_Device_Map \
      > ${DEVICE_MAP_RESCATUX_FILE_TMP_PATH}
  echo "${DEVICE_MAP_RESCATUX_FILE_TMP_PATH}"

} # function rtux_Order_Hard_Disks ()

# Install Grub from the choosen Linux partition to the choosen hard disk
# 1 parametre = Selected hard disk
# 2 parametre = Selected partition
# 3 parametre = Rescatux Device Map File Path
# While it is being run user is shown the hard disks
# and it is asked to order them
function rtux_Grub_Install () {

  local EXIT_VALUE=1 # Error by default
  local SELECTED_HARD_DISK="$1"
  local SELECTED_PARTITION="$2"
  local DEVICE_MAP_RESCATUX_FILE_TMP_PATH="$3";

  local SELECTED_HARD_DISK_DEV="/dev/${SELECTED_HARD_DISK}"
  local n_partition=${SELECTED_PARTITION}

  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}
  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
    mount -o bind /dev ${TMP_MNT_PARTITION}/dev
    mount -o bind /proc ${TMP_MNT_PARTITION}/proc
    mount -o bind /sys ${TMP_MNT_PARTITION}/sys

    # Generate tmp fstab
    TMP_FSTAB=$(rtux_make_tmp_fstab "${TMP_MNT_PARTITION}")

    if [[ -e ${TMP_MNT_PARTITION}${LINUX_OS_DETECTOR} ]] ; then
       cp ${DEVICE_MAP_RESCATUX_FILE_TMP_PATH} ${TMP_MNT_PARTITION}/${DEVICE_MAP_RESCATUX_STR}


      # TODO: Improve with a cat command ended with a EOF mark
      local TMP_SCRIPT="/tmp/$$.sh"
      local TMP_MNT_PARTITION_SCRIPT="${TMP_MNT_PARTITION}${TMP_SCRIPT}"

      rtux_File_Chroot_Script_Device_Map \
      "if ${GRUB_INSTALL_BINARY}.unsupported --version ; then " \
      "${GRUB_INSTALL_BINARY}.unsupported ${SELECTED_HARD_DISK_DEV} ;"\
      " elif ${GRUB_INSTALL_BINARY} --version ; then " \
      "${GRUB_INSTALL_BINARY} ${SELECTED_HARD_DISK_DEV} ;" \
      " else " \
      "grub2-install ${SELECTED_HARD_DISK_DEV} ;" \
      "fi" \
      > ${TMP_MNT_PARTITION}${TMP_SCRIPT}

      chmod +x ${TMP_MNT_PARTITION_SCRIPT}

      # TODO: Let the user use other than now hard-coded /bin/bash
      mount -a --fstab "${TMP_FSTAB}"
      chroot ${TMP_MNT_PARTITION} /bin/bash ${TMP_SCRIPT}
      EXIT_VALUE=$?
      mount -t auto -o remount,rw ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} # Workaround
      rm ${TMP_MNT_PARTITION_SCRIPT}

    fi # Linux detector was found
    umount --recursive "${TMP_MNT_PARTITION}"
  fi # Partition was mounted ok

  return ${EXIT_VALUE}

} # function rtux_Grub_Install ()

# Update Grub configuration file from the choosen Linux partition
# 1 parametre = Selected partition
# 2 parametre = Rescatux Device Map File Path
# While it is being run user is shown the hard disks
# and it is asked to order them
function rtux_Grub_Update_Config () {
# TODO: Extract last user interaction (Success/Failure)
# So that this function returns being successful or not

  local EXIT_VALUE=1 # Error by default
  local SELECTED_PARTITION=$1;
  local DEVICE_MAP_RESCATUX_FILE_TMP_PATH=$2;
  local n_partition=${SELECTED_PARTITION}

  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}

  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null)
    then
    mount -o bind /dev ${TMP_MNT_PARTITION}/dev
    mount -o bind /proc ${TMP_MNT_PARTITION}/proc
    mount -o bind /sys ${TMP_MNT_PARTITION}/sys

    # Generate tmp fstab
    TMP_FSTAB=$(rtux_make_tmp_fstab "${TMP_MNT_PARTITION}")

    if [[ -e ${TMP_MNT_PARTITION}${LINUX_OS_DETECTOR} ]] ; then
      cp ${DEVICE_MAP_RESCATUX_FILE_TMP_PATH} ${TMP_MNT_PARTITION}/${DEVICE_MAP_RESCATUX_STR}


      # TODO: Improve with a cat command ended with a EOF mark
      local TMP_SCRIPT="/tmp/$$.sh"
      local TMP_MNT_PARTITION_SCRIPT="${TMP_MNT_PARTITION}${TMP_SCRIPT}"

      rtux_File_Chroot_Script_Device_Map \
      "if ${UPDATE_GRUB_BINARY} --version ; then " \
      "${UPDATE_GRUB_BINARY} ; "\
      "elif update-grub2 --version ; " \
      "then update-grub2 ; " \
      "elif grub2-mkconfig --version ; " \
      "then grub2-mkconfig -o /boot/grub2/grub.cfg ;"\
      "else grub-mkconfig -o /boot/grub/grub.cfg ; "\
      "fi" \
      > ${TMP_MNT_PARTITION}${TMP_SCRIPT}

      chmod +x ${TMP_MNT_PARTITION_SCRIPT}

      # TODO: Let the user use other than now hard-coded /bin/bash
      mount -a --fstab "${TMP_FSTAB}"
      chroot ${TMP_MNT_PARTITION} /bin/bash ${TMP_SCRIPT}
      EXIT_VALUE=$?
      mount -t auto -o remount,rw ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} # Workaround
      rm ${TMP_MNT_PARTITION_SCRIPT}


    fi # Linux detector was found
    umount --recursive "${TMP_MNT_PARTITION}"
  fi # Partition was mounted ok

  return ${EXIT_VALUE}

} # function rtux_Grub_Update_Config ()

# Forces a fsck of a partition
# 1 parametre = Selected partition
function rtux_Fsck_Forced () {
  local SELECTED_PARTITION=$1
  local EXIT_VALUE=1 # Error by default

  fsck -fy /dev/${SELECTED_PARTITION}
  EXIT_VALUE=$?
  return ${EXIT_VALUE}

} # rtux_Fsck_Forced ()

# Shows progress when running a task
# 1st parametre = Running Message
# All parametre = What to be run
function rtux_Run_Show_Progress () {
  local EXIT_VALUE=1 # Error by default
  local RUNNING_STR="$1"
  shift
  "$@" \
  | tee >(zenity ${ZENITY_COMMON_OPTIONS} \
	--text "${RUNNING_STR}" \
	--progress \
	--pulsate \
	--auto-close) >> /dev/stdout
  EXIT_VALUE=${PIPESTATUS[0]}
  return ${EXIT_VALUE}

} # rtux_Run_Show_Progress ()

# TODO: Program check runtime (Maybe to be stolen from bootinfoscript)

# No parametres
# Choose UEFI Boot Order
# While it is being run user is shown the UEFI boot entries
# and it is asked to order them
# Outputs desired order ( E.g.: 0002,0001,0000 )
function rtux_Choose_UEFI_Boot_Order_Update () {
# TODO: Extract last user interaction (Success/Failure)
# So that this function returns being successful or not

  local EXIT_VALUE=1 # Error by default

  # TODO: Check if we are in UEFI system and warn the user


  local COLUMN_NUMBER=2 # Determine UEFI entry id column and UEFI entry description column

  local UEFI_ENTRY_NUMBER=0
  for nline in $(${EFIBOOTMGR_BINARY} | grep -E '^Boot[0-9][0-9][0-9][0-9]') ; do
    let UEFI_ENTRY_NUMBER=UEFI_ENTRY_NUMBER+1
    id_arranque="$(echo $nline | cut -c 5-8)"
  done

  if [ ${UEFI_ENTRY_NUMBER} -gt 1 ] ; then
    ARGS_ARRAY_INDEX=0
    ARGS_ARRAY[ARGS_ARRAY_INDEX]=${COLUMN_NUMBER}
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="${UEFIORDER_WTITLE}"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="${ORDER_UEFIORDER_STR}"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="UEFI ID"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
    ARGS_ARRAY[ARGS_ARRAY_INDEX]="Description"
    let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1


    while read -r nline ; do
      id_arranque=$(echo "${nline}" | cut -c 5-8)
      descripcion_arranque=$(echo "${nline}" | awk '{$1="";print $0}' | awk '{$1=$1;print $0}')

      ARGS_ARRAY[ARGS_ARRAY_INDEX]="${id_arranque}"
      let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1
      ARGS_ARRAY[ARGS_ARRAY_INDEX]="${descripcion_arranque}"
      let ARGS_ARRAY_INDEX=${ARGS_ARRAY_INDEX}+1

    done < <( ${EFIBOOTMGR_BINARY} | grep -E '^Boot[0-9][0-9][0-9][0-9]' )
    TMP_DESIRED_ORDER=`${RESCATUX_PATH}order.py "${ARGS_ARRAY[@]}"`
    # Put commas in place - Begin
    FIRST_ENTRY_FOUND='true'
    DESIRED_ORDER=""
    for nentry in ${TMP_DESIRED_ORDER} ; do
    if [ "$FIRST_ENTRY_FOUND" == "true" ]
        then
          DESIRED_ORDER="${nentry}";
          FIRST_ENTRY_FOUND='false' ;
        else
          DESIRED_ORDER="${DESIRED_ORDER},${nentry}";
    fi
    done
    # Put commas in place - End

  else
    DESIRED_ORDER="${id_arranque}"
  fi

	echo "${DESIRED_ORDER}"

} # function rtux_Choose_UEFI_Boot_Order_Update ()

# $1 : Uefi Boot Order (E.g: 0000,0002,001 )
# Update UEFI Boot Order
function rtux_UEFI_Boot_Order_Update () {
# TODO: Extract last user interaction (Success/Failure)
# So that this function returns being successful or not

  local EXIT_VALUE=1 # Error by default

  local DESIRED_ORDER="$1"

  # TODO: Check if we are in UEFI system and warn the user

  ${EFIBOOTMGR_BINARY} -o ${DESIRED_ORDER}
  EXIT_VALUE=$?

  return ${EXIT_VALUE}

} # function rtux_UEFI_Boot_Order_Update ()

# $1 : Partition to check (E.g. sda2)
# Check if a partition is an EFI System partition
function rtux_UEFI_Check_Is_EFI_System_Partition () {

  local EXIT_VALUE=1 # Error by default

  local efi_partition_to_check="$1"
  local efi_partition_hard_disk="$(echo ${efi_partition_to_check} | sed 's/[0-9]*$//g' 2> /dev/null)"
  fdisk -lu /dev/${efi_partition_hard_disk} \
       | grep '^/dev/'"${efi_partition_to_check}"'\+[[:space:]]\+' \
       | grep "${FDISK_EFI_SYSTEM_DETECTOR}"'$' \
       > /dev/null 2>&1
  EXIT_VALUE=$?

  return ${EXIT_VALUE}

} # function rtux_UEFI_Check_Is_EFI_System_Partition ()

# Let the user choose his main EFI System partition
# It outputs choosen partition
function rtux_Choose_EFI_System_partition () {
  rtux_Abstract_Choose_Partition $(rtux_Get_EFI_System_Partitions)
} # function rtux_Choose_EFI_System_partition ()

function rtux_Get_EFI_System_Partitions() {
  GET_EFI_SYSTEM_PARTITIONS_RUNNING_STR="Getting EFI System partitions."
  rtux_Run_Show_Progress "${GET_EFI_SYSTEM_PARTITIONS_RUNNING_STR}" rtux_Get_EFI_System_Partitions_payload "$@"
} # function rtux_Get_EFI_System_Partitions ()

# Return partitions which are EFI System partitions
function rtux_Get_EFI_System_Partitions_payload() {
  local TARGET_PARTITIONS=$(rtux_Get_System_Partitions)
  local EFI_SYSTEM_PARTITIONS=""

  for n_partition in ${TARGET_PARTITIONS}; do
    if rtux_UEFI_Check_Is_EFI_System_Partition ${n_partition} ; then
      EFI_SYSTEM_PARTITIONS="${EFI_SYSTEM_PARTITIONS} ${n_partition}"
    fi
  done

  echo "${EFI_SYSTEM_PARTITIONS}"
} # function rtux_Get_EFI_System_Partitions_payload ()

# $1 : Uefi EFI Partition # sda2
# $2 : EFI relative Complete File path # EFI/Boot/bootx64.efi
# Update UEFI Boot Order
function rtux_UEFI_Add_Boot_Entry () {
# TODO: Extract last user interaction (Success/Failure)
# So that this function returns being successful or not

  local EXIT_VALUE=1 # Error by default

  local UEFI_EFI_PARTITION="$1"
  local UEFI_EFI_RELATIVE_FILEPATH="$2"

  # TODO: Check if we are in UEFI system and warn the user

  # Convert EFI PARTITION into EFI disk
  local TMP_UEFI_EFI_DISK="$(echo ${UEFI_EFI_PARTITION} | sed 's/[0-9]*$//g')" # sda21 -> sda
  local UEFI_EFI_DISK="/dev/${TMP_UEFI_EFI_DISK}"

  # Convert EFI PARTITION into partition number
  local UEFI_EFI_PARTITION_NUMBER="$(echo ${UEFI_EFI_PARTITION} | grep -o '[0-9]*$')"
  # Convert File path into EFI ready file path
  local UEFI_EFI_READY_FILEPATH="\\$(echo ${UEFI_EFI_RELATIVE_FILEPATH} \
                                       | sed 's~/~\\~g' \
                                       | tr '[:upper:]' '[:lower:]')" # EFI/Boot/bootx64.efi -> \efi\boot\bootx64.efi
  # Convert File path into EFI label
  local UEFI_EFI_LABEL="${UEFICREATE_BOOT_ENTRY_PREFIX}${UEFI_EFI_READY_FILEPATH}"

  ${EFIBOOTMGR_BINARY} \
    -c \
    -d "${UEFI_EFI_DISK}" \
    -p ${UEFI_EFI_PARTITION_NUMBER} \
    -L "${UEFI_EFI_LABEL}" \
    -l "${UEFI_EFI_READY_FILEPATH}"

  # efibootmgr -c -d /dev/sda -p 2 -L "Gentoo" -l "\efi\boot\bootx64.efi"
  EXIT_VALUE=$?

  return ${EXIT_VALUE}

} # function rtux_UEFI_Add_Boot_Entry ()

# $1 : Uefi EFI Partition # sda2
function rtux_UEFI_Choose_EFI_File () {

  UEFI_EFI_FILE_CHOOSE_STR="Please choose a EFI file"
  UEFI_FILE_STR="EFI file"

  local UEFI_EFI_PARTITION="$1"
  local n_partition=${UEFI_EFI_PARTITION}

  local TMP_MNT_PARTITION=${RESCATUX_ROOT_MNT}/${n_partition}
  local TMP_DEV_PARTITION=/dev/${n_partition}
  mkdir --parents ${TMP_MNT_PARTITION}

  if $(mount -t auto ${TMP_DEV_PARTITION} ${TMP_MNT_PARTITION} 2> /dev/null) ; then

    m=1

    while read -r ffile ; do
      BFILE="$ffile"
      if [[ m -eq 1 ]] ; then
        UEFI_EFI_LIST_VALUES="TRUE ${BFILE}"
      else
        UEFI_EFI_LIST_VALUES="${UEFI_EFI_LIST_VALUES} FALSE ${BFILE}"
      fi
      let m=m+1
    done < <( find ${TMP_MNT_PARTITION} -iname '*\.efi' | sed 's~^'"${TMP_MNT_PARTITION}"'/~~g' )

    SELECTED_FILE=$(zenity ${ZENITY_COMMON_OPTIONS} \
      --list  \
      --text "${LOG_CHOOSE_STR}" \
      --radiolist  \
      --column "${SELECT_STR}" \
      --column "${UEFI_FILE_STR}" \
      ${UEFI_EFI_LIST_VALUES});

    umount ${TMP_MNT_PARTITION} > /dev/null 2>&1
    echo "${SELECTED_FILE}"

  fi


} # function rtux_UEFI_Choose_EFI_File ()


# Rescatux lib main variables

RESCATUX_URL="http://www.supergrubdisk.org/rescatux/"
RESCATUX_IRC_URL="irc://irc.freenode.net/rescatux"
RESCATUX_PASTEBIN_URL="http://paste.debian.net"
RESC_USER_IRC_PREFIX="resc_"

RESCAPP_WIDTH="600"
RESCAPP_HEIGHT="400"
ZENITY_COMMON_OPTIONS="--width=${RESCAPP_WIDTH} \
		       --height=${RESCAPP_HEIGHT}"

EXIT_STR="Exit"

RUN_STR="Run"

FIREFOX_COMMAND="xdg-open"
GEDIT_COMMAND="xdg-open"
XCHAT_COMMAND="xchat"
FDISK_COMMAND="/sbin/fdisk"
FILEMANAGER_COMMAND="xdg-open"

FIREFOX_WINDOW_STR="Iceweasel"
XCHAT_WINDOW_STR="Xchat"

CODE_STR="Code"
NAME_STR="Name"
DESCRIPTION_STR="Description"
WHICH_PARTITION_STR="Which partition?"
WHICH_USER_STR="Which user?"
SELECT_STR="Select"
ENTER_PASS_STR="Enter password"
PARTITION_STR="Partition"
FILESYSTEM_STR="File system"
NO_FILESYSTEM_STR="No file system"
FLAGS_STR="Flags"
NO_FLAGS_STR="No flags"
OSPROBER_LONGNAME_STR="Guessed long name"
NO_OSPROBER_LONGNAME_STR="No long name guessed"
USER_STR="User"
POSITION_STR="Position"
HARDDISK_STR="Hard Disk"
SIZE_STR="Size"

ORDER_HDS_WTITLE="Order hard disks"
ORDER_HDS_STR="Order hard disks according to boot order. Press OK to continue."
RIGHT_HD_POSITION_STR="Which is the right position for this hard disk?"
SUCCESS_STR="Success!"
INFO_STR="Information"
FAILURE_STR="Failure!"
NOT_DETECTED_STR="Windows / Data / Other"
EFI_SYSTEM_STR="EFI System"
CANT_MOUNT_STR="Cannot mount"
RUNNING_STR="Running process... Please wait till finish message appears."

UEFIORDER_WTITLE="Order UEFI boot entries"
ORDER_UEFIORDER_STR="Order UEFI boot entries in the other you want. Press OK to continue."
RIGHT_UEFIORDER_STR="Which is the right position for this UEFI boot entry?"
UEFICREATE_BOOT_ENTRY_PREFIX="(Rescapp added) "


PROC_PARTITIONS_FILE=/proc/partitions

RESCATUX_ROOT_MNT=/mnt/rescatux
LINUX_OS_DETECTOR="/etc/issue"
GRUB_INSTALL_BINARY=grub-install
ETC_ISSUE_PATH="/etc/issue"
UEFI_DETECTION_DIR="/sys/firmware/efi"
FDISK_EFI_SYSTEM_DETECTOR="EFI System"

TMP_FOLDER="/tmp"

DEVICE_MAP_RESCATUX_STR="device.map.rescatux"
DEVICE_MAP_BACKUP_STR="device.map.rescatux.backup"

UPDATE_GRUB_BINARY=update-grub
EFIBOOTMGR_BINARY=efibootmgr





