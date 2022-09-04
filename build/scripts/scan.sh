#!/bin/sh

IMAGE="$1"

echo "Scanning ${IMAGE} . . ."

# DEFINE VARIABLES
SCANLOGS_DIR="/var/log/scan-logs"
COMBINED_LOGFILE="${SCANLOGS_DIR}/combined/${IMAGE}.json"
SPLIT_LOGDIR="${SCANLOGS_DIR}/individual/${IMAGE}"
TMPFILE="/tmp/${IMAGE}.json"

# SETUP DIRECTORIES
mkdir -p "$(dirname "${COMBINED_LOGFILE}")"
rm -rf "${SPLIT_LOGDIR}"
mkdir -p "${SPLIT_LOGDIR}"
mkdir -p "$(dirname "${TMPFILE}")"
chmod 755 "${SCANLOGS_DIR}"
find "${SCANLOGS_DIR}" -type d -exec sh -c "chmod 755 {}" \;
find "${SCANLOGS_DIR}" -type f -exec sh -c "chmod 644 {}" \;

# SCAN IMAGE
trivy image ${IMAGE} --security-checks vuln -f json -o "${TMPFILE}"

# CAPTURE THE FULL RESULTS
jq -c -r --arg date "$(date +"%Y-%m-%dT%H:%M:%S%z")" '{"ScanTime": $date} + . | .ScanTime = $date' "${TMPFILE}" >"${COMBINED_LOGFILE}"

# PARSE RESULTS INTO INDIVIDUAL ARRAYS
VULNERABILITIES="$(jq -c -r '[(. | del(.Results)) + (.Results[] | del(.Vulnerabilities)) + .Results[].Vulnerabilities[]]' "${COMBINED_LOGFILE}")"

# DUMP ARRAYS TO INDIVIDUAL FILES
i=0
for row in $(echo "${VULNERABILITIES}" | jq -r '.[] | @base64'); do
	i=$((i+1))
    _jq() {
		echo ${row} | base64 -d | jq -c -r ${1}
    }
	echo $(_jq '.') >"${SPLIT_LOGDIR}/${i}.json"
done
