#!/bin/sh

IMAGE="$1"

echo "Scanning ${IMAGE} . . ."

# DEFINE VARIABLES
SCANLOGS_DIR="/var/log/scan-logs"
COMBINED_LOGFILE="${SCANLOGS_DIR}/combined/${IMAGE}.json"
SPLIT_LOGDIR="${SCANLOGS_DIR}/individual/${IMAGE}"
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
trivy image ${IMAGE} --security-checks vuln --ignore-unfixed -f json -o "${COMBINED_TMPFILE}"

# CAPTURE THE FULL RESULTS
jq -c -r --arg date "$(date +"%Y-%m-%dT%H:%M:%S%z")" '{"ScanTime": $date} + . | .ScanTime = $date' "${COMBINED_TMPFILE}" >"${COMBINED_LOGFILE}"

# PARSE RESULTS INTO INDIVIDUAL ARRAYS
VULNERABILITIES="$(jq -c -r '[(. | del(.Results)) + (.Results[] | del(.Vulnerabilities)) + .Results[].Vulnerabilities[]]' "${COMBINED_LOGFILE}")"

# DUMP ARRAYS TO INDIVIDUAL FILES
i=0
for row in $(echo "${VULNERABILITIES}" | jq -r '.[] | @base64'); do
	i=$((i+1))
    _jq() {
		echo ${row} | base64 -d | jq -c -r ${1}
    }
	echo $(_jq '.') >"${SPLIT_TMPDIR}/${i}.json"
	mv "${SPLIT_TMPDIR}/${i}.json" "${SPLIT_LOGDIR}/${i}.json"
done

# REMOVE THE TEMPDIR
rm -rf "${SPLIT_TMPDIR}"
