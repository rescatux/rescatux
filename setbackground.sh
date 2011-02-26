#!/bin/bash
LIVE_HOME="/home/user"
MAGIC_BACKGROUND_FILENAME="background.png"
gconftool-2 -t str --set /desktop/gnome/background/picture_filename "${LIVE_HOME}/Desktop/logos/${MAGIC_BACKGROUND_FILENAME}"

