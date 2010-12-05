#!/bin/bash 


# TODO: Put background colour in a single variable
# TODO: Put development font colour in a variable
# TODO: Put version string colour in a variable
# TODO: Change some variables with Rescatux in its name and replace it with Distro

# TODO: Ask help on imagemagick channel on how to do all the converts in a single command with kind of internal convert variables




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
TMP_RIGHT_LATERAL_FILENAME="temporal_right_lateral.png"

COMMON_LOGO_WIDTH="140" # TODO: Extract value from png itself
COMMON_LOGO_HEIGHT="230" # Not used

SYSLINUX_WIDTH="640"
SYSLINUX_HEIGHT="400"

SUPPORT_LOGO_WIDTH="60"
SUPPORT_LOGO_HEIGHT="35"

SUPPORT_MSG_HEIGHT="100" # This is kind of font size

RESCATUX_VERSION_STRING_WIDTH="$(( ${SYSLINUX_WIDTH} - ${COMMON_LOGO_WIDTH} ))"
RESCATUX_VERSION_STRING_HEIGHT="$(( ${SYSLINUX_HEIGHT} - ${SUPPORT_MSG_HEIGHT} ))"

SUPPORT_MSG_WIDTH="$(( ${RESCATUX_VERSION_STRING_WIDTH} - ${SUPPORT_LOGO_WIDTH} ))"



# This algorithm supposes that you want the common logo at the left side

# Expand Rescatux's tux so that it is as big as syslinux height
convert -background yellow2 -gravity center -extent ${COMMON_LOGO_WIDTH}x${SYSLINUX_HEIGHT}! ${COMMON_LOGO_FILENAME} ${COMMON_LOGO_EXPANDED_FILENAME}

# Generate "Rescatux X.XX" string
convert \
    -background yellow2 \
    -fill red \
    -strokewidth 2  \
    -stroke OrangeRed   \
    -undercolor yellow \
    -size ${RESCATUX_VERSION_STRING_WIDTH}x${RESCATUX_VERSION_STRING_HEIGHT} \
    -gravity south \
    label:"${RESCATUX_STR} ${VERSION}" \
    ${RESCATUX_VERSION_STRING}.png

# Generate development message string without logo
convert \
    -background yellow2 \
    -fill black \
    -strokewidth 1  \
    -stroke black   \
    -undercolor yellow \
    -size ${SUPPORT_MSG_WIDTH}x${SUPPORT_MSG_HEIGHT} \
    -gravity north \
    label:"${SUPPORT_MSG}" \
    ${SUPPORT_MSG_FILENAME_STR}
# Add logo to development message
convert +append ${SUPPORT_MSG_FILENAME_STR} ${SUPPORT_LOGO_FILENAME} ${SUPPORT_MSG_PLUS_LOGO_FILENAME}

# Generate right lateral part of the image
convert -append ${SUPPORT_MSG_PLUS_LOGO_FILENAME} ${RESCATUX_VERSION_STRING}.png ${TMP_RIGHT_LATERAL_FILENAME}

# Merge left expanded distro logo with the rest of the image's right lateral
convert +append ${COMMON_LOGO_EXPANDED_FILENAME} ${TMP_RIGHT_LATERAL_FILENAME} ${LOGO_FILENAME_STR}.png

convert -colors 14 ${LOGO_FILENAME_STR}.png ${LOGO_FILENAME_STR}.ppm

ppmtolss16 '#d0d0d0=7' < "${LOGO_FILENAME_STR}".ppm > "${FINAL_RLE_FILE}"


# Delete temporal image files
rm ${COMMON_LOGO_EXPANDED_FILENAME} \
${RESCATUX_VERSION_STRING}.png \
${SUPPORT_MSG_FILENAME_STR} \
${SUPPORT_MSG_PLUS_LOGO_FILENAME} \
${TMP_RIGHT_LATERAL_FILENAME} \
${LOGO_FILENAME_STR}.png \
${LOGO_FILENAME_STR}.ppm

