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


RESCAPP_WIDTH="800"
RESCAPP_HEIGHT="400"
ZENITY_COMMON_OPTIONS="--width=${RESCAPP_WIDTH} \
		       --height=${RESCAPP_HEIGHT}"

CHANGE_MONITOR_SETTINGS_QUESTION_TITLE="Rescatux-Startup-Wizard"
CHANGE_MONITOR_SETTINGS_QUESTION_STR="Do you want to change your monitor settings?"


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


function rtux_change_monitor_settings_question() {

    zenity ${ZENITY_COMMON_OPTIONS} \
      --title "${CHANGE_MONITOR_SETTINGS_QUESTION_TITLE}"\
	  --question  \
	  --text "${CHANGE_MONITOR_SETTINGS_QUESTION_STR}"

} # rtux_change_monitor_settings()


if rtux_change_monitor_settings_question ; then
    rtux_run_and_center_monitor_settings
else
    echo "Starting monitor settings was skipped"
fi




