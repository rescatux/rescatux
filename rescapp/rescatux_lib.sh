#!/bin/bash
# Rescapp Rescatux main library: rescatux_lib
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
	sed -e 's/\\. //g' -e 's/\\.//g' -e 's/^[ \t]*//' -e 's/\ /_/g' -e 's/\ \ /_/g' -e 's/\n/_/g' -e 's/--/_/g')
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
function rtux_File_Reordered_Device_Map() {


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

} # rtux_File_Reordered_Device_Map()

# 1 parametre = Passwd filename
# Return users list from passwd
function rtux_User_List() {
  PASSWD_FILENAME="$1"
  awk -F : '{print $1}' "${PASSWD_FILENAME}" | tr '\n' ' '
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
function rtux_make_tmp_fstab() {

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

} # rtux_make_tmp_fstab()

function rtux_backup_windows_config () {

  SAM_FILE="$1"
  PRE_RESCATUX_STR="PRE_RESCATUX"
  CURRENT_SECOND_STR="$(date +%Y-%m-%d-%H-%M-%S)"
  SAM_DIR="$(dirname ${SAM_FILE})"
  cp -r "${SAM_DIR}" "${SAM_DIR}_${PRE_RESCATUX_STR}_${CURRENT_SECOND_STR}"

}

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

# Reset windows password
# 1 parametre = Selected partition
function rtux_winpass_reset () {

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
  # Backup of the files in a temporal folder
      rtux_backup_windows_config "${SAM_FILE}"
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


  # Ask the user which password to reset
      CHOOSEN_USER=$(rtux_Choose_Sam_User \
      "Choose Windows user to reset its password")
  # Run chntpw -L sam-file security-file
	sampasswd -E -r -u "0x${CHOOSEN_USER}" ${SAM_FILE};
	EXIT_VALUE=$?
  # Umount the partition

    umount ${TMP_MNT_PARTITION};
  fi # Partition was mounted ok

  return ${EXIT_VALUE};

} # rtux_winpass_reset ()

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
USER_STR="User"
POSITION_STR="Position"
HARDDISK_STR="Hard Disk"
SIZE_STR="Size"

ORDER_HDS_WTITLE="Order hard disks"
ORDER_HDS_STR="Order hard disks according to boot order. Press OK to continue."
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






