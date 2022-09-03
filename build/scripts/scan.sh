#!/bin/sh

SCANLOGS_DIR="/var/log/scan-logs"

echo "Scanning $1 . . ."
LOGFILE="${SCANLOGS_DIR}/$1.json"
LOGDIR="$(dirname ${LOGFILE})"
if [ ! -d "${LOGDIR}" ]; then
	mkdir -p "${LOGDIR}"
fi
trivy image $1 --security-checks vuln -f json -o "${LOGFILE}"
