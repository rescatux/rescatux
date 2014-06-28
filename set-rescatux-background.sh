#!/bin/bash
# Rescapp LXDE Set Background script
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

LIVE_HOME="/home/user"
MAGIC_BACKGROUND_FILENAME="background.png"
feh --bg-fill "/usr/share/rescatux-data/logos/${MAGIC_BACKGROUND_FILENAME}"
pcmanfm --set-wallpaper "/usr/share/rescatux-data/logos/${MAGIC_BACKGROUND_FILENAME}"
pcmanfm --desktop &disown
sudo cp "${LIVE_HOME}/Desktop/rescapp/chntpw" /usr/sbin/
sudo chmod +x /usr/sbin/chntpw
mkdir --parents ${LIVE_HOME}/.local/share/applications
cat << EOF > ${LIVE_HOME}/.local/share/applications/mimeapps.list
[Added Associations]
text/plain=leafpad.desktop;

EOF