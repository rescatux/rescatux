#!/bin/bash

function show_menu() {

OPTIONS_FILE=${1}.${LIST_FILE_SUFFIX}
MENU_TITLE=$1

choice="$(find `cat ${OPTIONS_FILE}` -maxdepth 1 -type d -exec cat {}/$DIRECTORY_FILE_STR {}/$NAME_FILE_STR {}/$DESCRIPTION_FILE_STR \; | zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "${CODE_STR}" --column "${NAME_STR}" --column "${DESCRIPTION_STR}" --title="${MENU_TITLE}" \
)";

result=$?

case $result in
0)
  show_item $choice
;;
1)

exit;
;;
esac

}

function show_item() {

DIRECTORY=$1

unset zenity_option_line
declare -a zenity_option_line
let n_zenity_option_line=0


if [ -e ${DIRECTORY}.${LIST_FILE_SUFFIX} ] ; then
  show_menu ${DIRECTORY}
else

  # Add run option if there is the run file
  if [ -e ${DIRECTORY}/${RUN_FILE_STR} ] ; then
    zenity_option_line[$n_zenity_option_line]="${RUN_CODE}"
    let n_zenity_option_line=n_zenity_option_line+1
    zenity_option_line[$n_zenity_option_line]="${RUN_STR}"
    let n_zenity_option_line=n_zenity_option_line+1
  fi

  # Add local documentation option if there is the local_doc.html file
  if [ -e ${DIRECTORY}/${LOCAL_FILE_STR} ] ; then
    zenity_option_line[$n_zenity_option_line]="${LOCAL_DOC_CODE}"
    let n_zenity_option_line=n_zenity_option_line+1
    zenity_option_line[$n_zenity_option_line]="${LOCAL_DOC_STR}"
    let n_zenity_option_line=n_zenity_option_line+1
  fi

  # Add online documentation option if there is the online_doc.html file
  if [ -e ${DIRECTORY}/${ONLINE_FILE_STR} ] ; then
    zenity_option_line[$n_zenity_option_line]="${ONLINE_DOC_CODE}"
    let n_zenity_option_line=n_zenity_option_line+1
    zenity_option_line[$n_zenity_option_line]="${ONLINE_DOC_STR}"
    let n_zenity_option_line=n_zenity_option_line+1
  fi


     choice="$(zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "${CODE_STR}" --column "${DESCRIPTION_STR}" --title="${DIRECTORY}" "${zenity_option_line[@]}")"
     result=$?

SUDO="sudo"
[ -e ${DIRECTORY}/sudo ] || SUDO=""

case $result in
0)


	case $choice in
	${RUN_CODE})
	exec ${SUDO} ${DIRECTORY}/${RUN_FILE_STR} > ${LOG_DIRECTORY}/${DIRECTORY}_log.txt 2>&1 &
	;;
	${LOCAL_DOC_CODE})
	${FIREFOX_COMMAND} --new-window ${DIRECTORY}/${LOCAL_DOC_STR} &
	;;
	${ONLINE_DOC_CODE})
	${FIREFOX_COMMAND} --new-window ${DIRECTORY}/${ONLINE_DOC_STR} &
	;;
	esac

;;
1)

return;
;;
esac

fi


}


# Main program
DEFAULT_PATH="${HOME}/Desktop/"
LOG_DIRECTORY="log"
LIST_FILE_SUFFIX="lis"
RESCAPP_WIDTH="600"
RESCAPP_HEIGHT="400"
GRUB_INSTALL_TO_MBR_STR="Restore GRUB / Fix Linux Boot"
CHAT_STR="Get online human help (chat)"
DOC_STR="Access online Rescatux website"
EXIT_STR="Exit"

RUN_CODE="run"
LOCAL_DOC_CODE="localdoc"
ONLINE_DOC_CODE="onlinedoc"

RUN_STR="Run"
LOCAL_DOC_STR="Local Documentation"
ONLINE_DOC_STR="Online Documentation"

FIREFOX_COMMAND="iceweasel"
GEDIT_COMMAND="gedit"


RUN_FILE_STR="run"
LOCAL_FILE_STR="local_doc.html"
ONLINE_FILE_STR="online_doc.html"
DIRECTORY_FILE_STR="directory"
NAME_FILE_STR="name"
DESCRIPTION_FILE_STR="description"


CODE_STR="Code"
NAME_STR="Name"
DESCRIPTION_STR="Description"

RESCAPP_TITLE_STR="RESCATUX's RESCAPP"


cd ${DEFAULT_PATH}

while true; do
choice="$(find `cat rescatux.lis` -maxdepth 1 -type d -exec cat {}/directory {}/name {}/description \; | zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "${CODE_STR}" --column "${NAME_STR}" --column "${DESCRIPTION_STR}" --title="${RESCAPP_TITLE_STR}" \
)";

result=$?

case $result in
0)
  show_item $choice
;;
1)

exit;
;;
esac

done

