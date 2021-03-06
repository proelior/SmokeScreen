#!/bin/sh
###############################################################################
. ${HOME}/.config/GSUITE/gsuite.conf

# If script is already running; abort.
if pidof -o %PPID -x "$(basename "$0")"; then
    echo "$(date "+%d.%m.%Y %T") INFO: $(basename "$0") already in progress. Aborting."
    exit 3
fi

echo  "$(date "+%d.%m.%Y %T") INFO: Starting Upload..."

find "$localdir" -type f |
while read n; do
	destpath="$(dirname "$n" | sed -e s@$localdir@@)"

	# Skip processing files named like the below
	case "${n}" in
		(*.partial~) continue ;;
		(*_HIDDEN~) continue ;;
		(*.QTFS) continue ;;
		(*.fuse*) continue ;;
	esac

	echo "$(date "+%d.%m.%Y %T") INFO: Processing file: ${n}"

	# If file is opened by another process, wait until it isn't.
	while [ $(lsof "$n" >/dev/null 2>&1) ]; do
		echo "File in use. Retrying in 10 seconds."
		sleep 10
	done

	echo "$(date "+%d.%m.%Y %T") INFO: copy to primary cloud storage"
	${rclonebin} move ${rcloneuploadoptions} "$n" "${primaryremote}:${cloudsubdir}${destpath}" 2>&1
done

exit 0


