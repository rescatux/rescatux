#!/bin/bash 

# Rescapp Generate logo
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

# TODO: Put background colour in a single variable
# TODO: Put development font colour in a variable
# TODO: Put version string colour in a variable
# TODO: Change some variables with Rescatux in its name and replace it with Distro

# TODO: Ask help on imagemagick channel on how to do all the converts in a single command with kind of internal convert variables


LOGOS_FOLDER="../logos"

RESCATUX_STR=$1
VERSION=$2
FINAL_RLE_FILE="$3"

RESCATUX_VERSION_STRING="rescatux_version_string"
COMMON_LOGO_FILENAME="rescatuxs_tux.png"
COMMON_LOGO_EXPANDED_FILENAME="rescatuxs_tux_expanded.png"
LOGO_FILENAME_STR="syslinux_rescatux_logo"
SUPPORT_MSG="Rescatux development is supported by BTACTIC."
SUPPORT_MSG_FILENAME_STR="rescatux_development_message.png"
SUPPORT_LOGO_FILENAME="btactic.png"
SUPPORT_MSG_PLUS_LOGO_FILENAME="rescatux_dev_plus_log_message.png"
TMP_BOTTOM_LATERAL_FILENAME="temporal_bottom_lateral.png"

COMMON_LOGO_WIDTH="298" # TODO: Extract value from png itself
COMMON_LOGO_HEIGHT="422" # Not used

SYSLINUX_WIDTH="640"
SYSLINUX_HEIGHT="480"

SUPPORT_LOGO_WIDTH="60"
SUPPORT_LOGO_HEIGHT="35"

HEADER_IMAGE_FILENAME="rescatux_header.png"
HEADER_HEIGHT="168" # Extracted manually from header file.

SUPPORT_MSG_HEIGHT="100" # This is kind of font size

RESCATUX_VERSION_STRING_WIDTH="$(( ${SYSLINUX_WIDTH} - ${COMMON_LOGO_WIDTH} ))"
RESCATUX_VERSION_STRING_HEIGHT="$(( ${SYSLINUX_HEIGHT} - ${HEADER_HEIGHT} ))"

SUPPORT_MSG_WIDTH="$(( ${RESCATUX_VERSION_STRING_WIDTH} - ${SUPPORT_LOGO_WIDTH} ))"



LOGO_HEIGHT="$(( ${SYSLINUX_HEIGHT} - ${HEADER_HEIGHT} ))"

# HEADER should be 640 witdth

# This algorithm supposes that you want the common logo at the left side

# Expand Rescatux's tux so that it is as big as syslinux height (minus header)
convert -background yellow2 -background white -undercolor white -gravity center -extent ${COMMON_LOGO_WIDTH}x${LOGO_HEIGHT}! ${COMMON_LOGO_FILENAME} ${COMMON_LOGO_EXPANDED_FILENAME}

# Generate "Rescatux X.XX" string
convert \
    -background white \
    -fill Orange \
    -strokewidth 2  \
    -stroke Orange   \
    -undercolor white \
    -size ${RESCATUX_VERSION_STRING_WIDTH}x${RESCATUX_VERSION_STRING_HEIGHT} \
    -gravity center \
    label:"${RESCATUX_STR} ${VERSION}" \
    ${RESCATUX_VERSION_STRING}.png

# Generate development message string without logo
#convert \
#    -background yellow2 \
#    -fill black \
#    -strokewidth 1  \
#    -stroke black   \
#    -undercolor yellow \
#    -size ${SUPPORT_MSG_WIDTH}x${SUPPORT_MSG_HEIGHT} \
#    -gravity north \
#    label:"${SUPPORT_MSG}" \
#    ${SUPPORT_MSG_FILENAME_STR}



# Add logo to development message
#convert +append ${SUPPORT_MSG_FILENAME_STR} ${SUPPORT_LOGO_FILENAME} ${SUPPORT_MSG_PLUS_LOGO_FILENAME}

# Generate right lateral part of the image
#convert -append ${SUPPORT_MSG_PLUS_LOGO_FILENAME} ${RESCATUX_VERSION_STRING}.png ${TMP_RIGHT_LATERAL_FILENAME}

# Merge left expanded distro logo with the rest of the image's right lateral
#convert +append ${COMMON_LOGO_EXPANDED_FILENAME} ${TMP_RIGHT_LATERAL_FILENAME} ${LOGO_FILENAME_STR}.png

convert +append ${COMMON_LOGO_EXPANDED_FILENAME} ${RESCATUX_VERSION_STRING}.png ${TMP_BOTTOM_LATERAL_FILENAME}

convert -append ${HEADER_IMAGE_FILENAME} ${TMP_BOTTOM_LATERAL_FILENAME} ${LOGO_FILENAME_STR}.png



convert -colors 14 ${LOGO_FILENAME_STR}.png ${LOGO_FILENAME_STR}.ppm

ppmtolss16 '#d0d0d0=7' < "${LOGO_FILENAME_STR}".ppm > "${FINAL_RLE_FILE}"

cp ${LOGO_FILENAME_STR}.png ${LOGOS_FOLDER}/background.png

# Delete temporal image files
rm ${COMMON_LOGO_EXPANDED_FILENAME} \
${RESCATUX_VERSION_STRING}.png \
${SUPPORT_MSG_FILENAME_STR} \
${SUPPORT_MSG_PLUS_LOGO_FILENAME} \
${TMP_BOTTOM_LATERAL_FILENAME} \
${LOGO_FILENAME_STR}.png \
${LOGO_FILENAME_STR}.ppm

