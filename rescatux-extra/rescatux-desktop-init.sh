#!/bin/bash
# Rescatux LXQT Init Script
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

function deal_with_two_monitors() {

    MONITOR_COUNT=$(xrandr --listactivemonitors | tail -n +2 | wc -l)

    if [ ${MONITOR_COUNT} -gt 1 ] ; then
      thetime="30"
      unit="s"
      increasefactor=$(echo "${thetime}"/100|bc -l)
      (
        counter=0
        while [ "$counter" -le 100 ]; do
          echo $counter; sleep "${increasefactor}""${unit}"
          counter=$(( $counter + 1 ))
        done
      ) |
      zenity --progress --title="Detected 2 or more screens." --text="Unless you press Cancel the detected screens will be auto-cloned with 1024x768 resolution in 30 seconds." --percentage=0 --auto-close
      if [ "$?" == 1 ]; then
        return 0
      else
        # Timed out: Let's clone the two monitors
        xrandr --listmonitors | sed -n '1!p' | sed -e 's/\s[0-9].*\s\([a-zA-Z0-9\-]*\)$/\1/g' | xargs -n 1 -- bash -xc 'xrandr --output $0 --mode '1024x768' --pos 0x0 --rotate normal'
      fi
    else
        # Only one monitor: Just return
        return 0
    fi

}

sleep 2s # Wait for the systray / desktop to come up

cmst --wait-time 5 --minimized &disown

# Start TightVNC Server - BEGIN
/usr/local/bin/rescatux-start-vnc-server.sh > /dev/null 2>&1 &disown
# Start TightVNC Server - END

# Start Rescatux startup wizard - BEGIN
deal_with_two_monitors
/usr/local/bin/rescatux-startup-wizard.sh > /dev/null 2>&1 &disown
# Start Rescatux startup wizard - END
