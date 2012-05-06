#!/bin/bash
# This script assumes apt-get install live-helper has been done
# This script assumes that the user has sudo permissions on lh build
IS_HYBRID="-hybrid"
MEDIA_STR="cdrom_usb_hybrid"
FILE_EXTENSION="iso"
LXDE_PACKAGES="lxde gdm3 network-manager-gnome"
PYTHON_PACKAGES="python-sip python-qt4"
RAID_PACKAGES="dmraid"
LVM_PACKAGES="lvm2"
SYNAPTIC_PACKAGES="synaptic"
PASSWD_PACKAGES="libsemanage1 libsemanage-common libustr-1.0-1"
#GNOME_MINIMAL_PACKAGES="gdm3 gedit gnome-core nautilus"
PACKAGES="${LXDE_PACKAGES} ${PYTHON_PACKAGES} ${RAID_PACKAGES} ${LVM_PACKAGES} ${PASSWD_PACKAGES} ${SYNAPTIC_PACKAGES} zenity iceweasel xchat syslinux pastebinit mbr ntfs-3g chntpw samdump2 bkhive gawk" # I add syslinux so that isohybrid command is recognised.
BOOT_OPTION="-b iso-hybrid"
LINUX_FLAVOURS="486 amd64"
source make_common
