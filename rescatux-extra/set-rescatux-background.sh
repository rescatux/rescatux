#!/bin/bash
# Rescatux LXQT Set Background script
# Copyright (C) 2012,2013,2014,2015,2016 Adrian Gibanel Lopez
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
MAGIC_BACKGROUND_PATH="/run/live/medium/isolinux/splash.png"

sleep 2s # Wait for the systray / desktop to come up
pcmanfm-qt --set-wallpaper "${MAGIC_BACKGROUND_PATH}"
pcmanfm-qt --desktop &disown
cmst --wait-time 5 --minimized &disown


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

# Start TightVNC Server - BEGIN
/usr/bin/start-rescatux-tightvnc-server.sh > /dev/null 2>&1 &disown
# Start TightVNC Server - END
