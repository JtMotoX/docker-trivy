#!/bin/sh

SCANLOGS_DIR="/var/log/scan-logs"

echo "Scanning $1 . . ."
LOGFILE="${SCANLOGS_DIR}/$1.json"
TMPFILE="/tmp/$1.json"
mkdir -p "$(dirname "${LOGFILE}")"
mkdir -p "$(dirname "${TMPFILE}")"
chmod 755 "${SCANLOGS_DIR}"
find "${SCANLOGS_DIR}" -type d -exec sh -c "chmod 755 {}" \;
find "${SCANLOGS_DIR}" -type f -exec sh -c "chmod 644 {}" \;
trivy image $1 --security-checks vuln -f json -o "${TMPFILE}"
jq -c --arg date "$(date +"%Y-%m-%dT%H:%M:%S%z")" '{"ScanTime": $date} + .' "${TMPFILE}" >"${LOGFILE}"
