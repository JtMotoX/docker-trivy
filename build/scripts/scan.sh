#!/bin/sh

set -e

IMAGE="$1"

echo "Scanning ${IMAGE} . . ."

# DEFINE VARIABLES
SCANLOGS_DIR="/var/log/scan-logs"
FILE_PREFIX="$(date "+%s")"
COMBINED_LOGFILE="${SCANLOGS_DIR}/combined/${FILE_PREFIX}_${IMAGE/\//+}.json"
SPLIT_LOGDIR="${SCANLOGS_DIR}/individual/${IMAGE/\//+}"
COMBINED_TMPFILE="/tmp/${IMAGE}.json"
SPLIT_TMPDIR="/tmp/${IMAGE}"

# SETUP DIRECTORIES
mkdir -p "$(dirname "${COMBINED_LOGFILE}")"
rm -rf "${SPLIT_LOGDIR}"
mkdir -p "${SPLIT_LOGDIR}"
mkdir -p "$(dirname "${COMBINED_TMPFILE}")"
mkdir -p "${SPLIT_TMPDIR}"
chmod 755 "${SCANLOGS_DIR}"
find "${SCANLOGS_DIR}" -type d -exec sh -c "chmod 755 {}" \;
find "${SCANLOGS_DIR}" -type f -exec sh -c "chmod 644 {}" \;

# SCAN IMAGE
touch "${COMBINED_TMPFILE}"
trivy image ${IMAGE} --security-checks vuln --ignore-unfixed -f json -o "${COMBINED_TMPFILE}"

# CAPTURE THE FULL RESULTS
cat "${COMBINED_TMPFILE}" | jq -c -r --arg date "$(date +"%Y-%m-%dT%H:%M:%S%z")" '{"ScanTime": $date} + . | .ScanTime = $date' >"${COMBINED_LOGFILE}"

# GET NUMBER OF VULNERABILITIES
VULNERABILITY_COUNT=$(cat "${COMBINED_LOGFILE}" | jq -r '.Results[]?.Vulnerabilities // empty' | jq -s 'flatten | length')
VULNERABILITY_COUNT=${VULNERABILITY_COUNT:-0}
if [ "${VULNERABILITY_COUNT}" -eq 0 ]; then
	echo "No vulnerabilities"
	exit 0
fi

# PARSE RESULTS INTO INDIVIDUAL ARRAYS
VULNERABILITIES="$(cat "${COMBINED_LOGFILE}" | jq -c -r '
	[
		(. | del(.Results)) +
		(.Results[] | del(.Vulnerabilities)) +
		(.Results[].Vulnerabilities | select(. != null) | .[])
	]
')"

# DUMP ARRAYS TO INDIVIDUAL FILES
i=0
for row in $(echo "${VULNERABILITIES}" | jq -r '.[] | @base64'); do
	i=$((i+1))
    _jq() {
		echo ${row} | base64 -d | jq -c -r ${1}
    }
	echo $(_jq '.') >"${SPLIT_TMPDIR}/${i}.json"
	mv "${SPLIT_TMPDIR}/${i}.json" "${SPLIT_LOGDIR}/${FILE_PREFIX}_${i}.json"
done

# REMOVE THE TEMPDIR
rm -rf "${SPLIT_TMPDIR}"
