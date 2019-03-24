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

# Remove any other running servers
killall -TERM x11vnc
# Start TightVNC Server - BEGIN
x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth ${LIVE_HOME}/.vnc/passwd -rfbport 5900 -shared
# Start TightVNC Server - END
