#!/bin/bash
# Rescatux Sart TightVNC server script
# Copyright (C) 2019 Adrian Gibanel Lopez
#
# Rescatux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescatux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescatux.  If not, see <http://www.gnu.org/licenses/>.

LIVE_HOME="/home/user"

RESCAPP_WIDTH="580"
RESCAPP_HEIGHT="350"
ZENITY_COMMON_OPTIONS="--width=${RESCAPP_WIDTH} \
		       --height=${RESCAPP_HEIGHT}"

CHANGE_MONITOR_SETTINGS_QUESTION_TITLE="Rescatux-Startup-Wizard"
CHANGE_MONITOR_SETTINGS_QUESTION_STR="Do you want to change your monitor settings?"

KEEP_X11VNC_QUESTION_TITLE="Rescatux-Startup-Wizard (2)"
KEEP_X11VNC_QUESTION_STR="Do you want to keep running VNC server (recommended answer: NO)?"

CHANGE_X11VNC_PASSWORD_QUESTION_TITLE="Rescatux-Startup-Wizard (3b)"
CHANGE_X11VNC_PASSWORD_QUESTION_STR="Do you want to change default VNC server password (rescatux) (recommended answer: YES)?"

NEWPASS_X11VNC_QUESTION_TITLE="Rescatux-Startup-Wizard (4b)"
NEWPASS_X11VNC_QUESTION_STR="Please write the VNC Server new password"
NEWPASS_X11VNC_QUESTION_ENTRY="New password here"

RESTART_X11VNC_INFO_TITLE="Rescatux-Startup-Wizard (5b)"
RESTART_X11VNC_INFO_STR="VNC Server will be restarted with new password. Press OK button."

NOPASSWORD_X11VNC_ERROR_TITLE="Rescatux-Startup-Wizard (5c)"
NOPASSWORD_X11VNC_ERROR_STR="We refuse to run X11VNC without a password or default password. It has been terminated."

START_RESCAPP_INFO_TITLE="Rescatux-Startup-Wizard (3/6b/6c)"
START_RESCAPP_INFO_STR="Rescatux startup wizard has been completed. Please press OK to start rescapp. Enjoy your recovery!"


function rtux_run_and_center_monitor_settings() {

    # Set monitor settings position - BEGIN
    MONITOR_SETTINGS_WINDOW_TITLE="Monitor Settings"
    lxqt-config-monitor > /dev/null 2>&1 &disown
    sleep 3s

    MONITOR1_WIDTH=$(xrandr --listactivemonitors | tail -n +2 | head -n 1 | awk '{print $3}' | awk -F '/' '{print $1}')
    MONITOR1_HALF_WIDTH="$(( ${MONITOR1_WIDTH} / 2 ))"
    MONITOR_COUNT=$(xrandr --listactivemonitors | tail -n +2 | wc -l)

    LXQT_CONFIG_MONITOR_WIDTH="$(wmctrl -l -G | grep "${MONITOR_SETTINGS_WINDOW_TITLE}" | awk '{print $5}')"
    LXQT_CONFIG_MONITOR_HALF_WIDTH="$(( ${LXQT_CONFIG_MONITOR_WIDTH} / 2 ))"

    if [ ${MONITOR_COUNT} -gt 1 ] ; then
        # More than one monitor means we need to put the program between those two monitors
        LXQT_CONFIG_MONITOR_NEW_X_OFFSET=$(( ${MONITOR1_WIDTH} - ${LXQT_CONFIG_MONITOR_HALF_WIDTH} ))
    else
        # Only one monitor: Just center in the middle of the screen
        LXQT_CONFIG_MONITOR_NEW_X_OFFSET=$(( ${MONITOR1_HALF_WIDTH} - ${LXQT_CONFIG_MONITOR_HALF_WIDTH} ))
    fi

    wmctrl -e 0,${LXQT_CONFIG_MONITOR_NEW_X_OFFSET},-1,-1,-1 -r "${MONITOR_SETTINGS_WINDOW_TITLE}"
    wmctrl -a "${MONITOR_SETTINGS_WINDOW_TITLE}"
# Set monitor settings position - END
}

function rtux_terminate_x11vnc_server() {
    killall -TERM x11vnc
}


function rtux_change_monitor_settings_question() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${CHANGE_MONITOR_SETTINGS_QUESTION_TITLE}"\
	  --question  \
	  --text "${CHANGE_MONITOR_SETTINGS_QUESTION_STR}"

} # rtux_change_monitor_settings()


function rtux_keep_x11vnc_server_question() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${KEEP_X11VNC_QUESTION_TITLE}"\
	  --question  \
	  --text "${KEEP_X11VNC_QUESTION_STR}"

} # rtux_keep_x11vnc_server_question()


function rtux_change_x11vnc_password_question() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${CHANGE_X11VNC_PASSWORD_QUESTION_TITLE}"\
	  --question  \
	  --text "${CHANGE_X11VNC_PASSWORD_QUESTION_STR}"

} # rtux_change_x11vnc_password_question()


function rtux_newpass_x11vnc_question() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${NEWPASS_X11VNC_QUESTION_TITLE}"\
	  --entry  \
	  --text "${NEWPASS_X11VNC_QUESTION_STR}" \
	  --entry-text "${NEWPASS_X11VNC_QUESTION_ENTRY}"

} # rtux_newpass_x11vnc_question()


function rtux_restart_x11vnc_info() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${RESTART_X11VNC_INFO_TITLE}"\
	  --info  \
	  --text "${RESTART_X11VNC_INFO_STR}"

} # rtux_restart_x11vnc_info()


function rtux_nopassword_x11vnc_error() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${NOPASSWORD_X11VNC_ERROR_TITLE}"\
	  --error  \
	  --text "${NOPASSWORD_X11VNC_ERROR_STR}"

} # rtux_restart_x11vnc_info()


if rtux_change_monitor_settings_question ; then
    rtux_run_and_center_monitor_settings
else
    echo "Starting monitor settings was skipped"
fi

function rtux_start_rescapp_info() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${START_RESCAPP_INFO_TITLE}"\
	  --info  \
	  --text "${START_RESCAPP_INFO_STR}"

} # rtux_restart_x11vnc_info()


if rtux_keep_x11vnc_server_question ; then
    if rtux_change_x11vnc_password_question ; then
        NEWPASS="$(rtux_newpass_x11vnc_question)"
        if [ -z "${NEWPASS}" ] || [ "${NEWPASS}" == "${NEWPASS_X11VNC_QUESTION_ENTRY}" ] ; then
            echo "Refusing to set X11VNC Server without a password"
            rtux_terminate_x11vnc_server
            rtux_nopassword_x11vnc_error
        else
            rtux_restart_x11vnc_info
            x11vnc -storepasswd "${NEWPASS}" ${LIVE_HOME}/.vnc/passwd
            rtux_terminate_x11vnc_server
            echo "Starting TightVNC server"
            /usr/bin/start-rescatux-tightvnc-server.sh > /dev/null 2>&1 &disown
        fi
    else
        echo "Skipping changing X11VNC password"
    fi
else
    rtux_terminate_x11vnc_server
fi

rtux_start_rescapp_info

rescapp > /dev/null 2>&1 &disown
