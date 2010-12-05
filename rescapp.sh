#!/bin/bash

function show_menu() {

OPTIONS_FILE=${1}.${LIST_FILE_SUFFIX}
MENU_TITLE=$1

choice="$(find `cat ${OPTIONS_FILE}` -maxdepth 1 -type d -exec cat {}/directory {}/name {}/description \; | zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "Code" --column "Name" --column "Description" --title="${MENU_TITLE}" \
)";

result=$?
echo -e -n "result is: $result\n"
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

if [ -e ${DIRECTORY}.${LIST_FILE_SUFFIX} ] ; then
  show_menu ${DIRECTORY}
else

choice="$(zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "Code" --column "Description" --title="${DIRECTORY}" "${RUN_CODE}" "${RUN_STR}" "${LOCAL_DOC_CODE}" "${LOCAL_DOC_STR}" "${ONLINE_DOC_CODE}" "${ONLINE_DOC_STR}")"

result=$?

SUDO="sudo"
[ -e ${DIRECTORY}/sudo ] || SUDO=""

echo -e -n "result is: $result\n"
case $result in
0)


	case $choice in
	${RUN_CODE})
	exec ${SUDO} ${DIRECTORY}/run > ${LOG_DIRECTORY}/${DIRECTORY}_log.txt 2>&1 &
	;;
	${LOCAL_DOC_CODE})
	${FIREFOX_COMMAND} --new-window ${DIRECTORY}/local_doc &
	;;
	${ONLINE_DOC_CODE})
	${FIREFOX_COMMAND} --new-window `cat ${DIRECTORY}/online_doc` &
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
DEFAULT_PATH="/home/user/Desktop/"
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

cd ${DEFAULT_PATH}

while true; do
choice="$(find `cat rescatux.lis` -maxdepth 1 -type d -exec cat {}/directory {}/name {}/description \; | zenity --width=${RESCAPP_WIDTH} --height=${RESCAPP_HEIGHT} --list --column "Code" --column "Name" --column "Description" --title="RESCATUX's RESCAPP" \
)";

result=$?
echo -e -n "result is: $result\n"
case $result in
0)
  show_item $choice
;;
1)

exit;
;;
esac

done

