#!/bin/bash
LIVE_HOME="/home/user"
MAGIC_BACKGROUND_FILENAME="background.png"
pcmanfm --set-wallpaper "${LIVE_HOME}/Desktop/rescapp/logos/${MAGIC_BACKGROUND_FILENAME}"
sudo cp "${LIVE_HOME}/Desktop/rescapp/chntpw" /usr/sbin/
sudo chmod +x /usr/sbin/chntpw
cat << EOF > ${LIVE_HOME}/.local/share/applications/mimeapps.list
[Added Associations]
text/plain=leafpad.desktop;
EOF