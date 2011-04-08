#!/bin/bash


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

FIREFOX_WINDOW_STR="Iceweasel"
XCHAT_WINDOW_STR="Xchat"

CODE_STR="Code"
NAME_STR="Name"
DESCRIPTION_STR="Description"