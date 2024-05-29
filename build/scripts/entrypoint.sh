#!/bin/sh

set -e

if [ "$1" = "run" ]; then
	if [ ! -d "${SCANLOGS_DIR}" ]; then
		echo "You must mount a directory to '${SCANLOGS_DIR}'"
		exit 1
	fi
	NOT_OWNED_BY_ROOT=$(find "${SCANLOGS_DIR}" \( -not -user $(id -u) -o -not -group $(id -g) \))
	if [ $(printf '%s' "${NOT_OWNED_BY_ROOT}" | wc -l) -ne 0 ]; then
		echo "ERROR: The mounted directory '${SCANLOGS_DIR}' must be owned by the app user and group (uid: $(id -u), gid: $(id -g))"
		echo "INFO: Example command to fix permissions: sudo chown -R $(id -u):$(id -g) $(basename "${SCANLOGS_DIR}")"
		exit 1
	fi

	echo "Starting cron"
	echo "${SCAN_SCHEDULE:-"0 0 * * *"} /scripts/scan-all.sh >/tmp/scan-all.log 2>&1" >>/crontab
	supercronic /crontab

	echo "Oops! Looks like cron stopped."
	exit 1
fi

exec "$@"
