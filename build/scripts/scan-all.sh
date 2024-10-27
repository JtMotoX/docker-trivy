#!/bin/sh

set -e

cd "$(dirname "$0")"

echo "Scanning images of all running containers . . ."

DOCKER_STDOUT_FILE="/tmp/docker-stdout.log"

IMAGES="$(sudo --preserve-env /scripts/list-images.sh 2>${DOCKER_STDOUT_FILE} | sort | uniq)"

DOCKER_STDOUT="$(cat ${DOCKER_STDOUT_FILE})"
rm -f "${DOCKER_STDOUT_FILE}"
if [ "${DOCKER_STDOUT}" != "" ]; then
	echo "There was an error getting container data"
	echo "${DOCKER_STDOUT}"
	exit 1
fi

TOTAL="$(echo "${IMAGES}" | wc -l)"

if [ "${TOTAL}" -le 0 ]; then
	echo "No Images found"
fi

SCANLOGS_DIR="${SCANLOGS_DIR:-"/var/log/scan-logs"}"
rm -rf "${SCANLOGS_DIR}/combined/"
rm -rf "${SCANLOGS_DIR}/individual/"

i=0
echo "${IMAGES}" | while read -r IMAGE; do
	i=$(( i + 1 ))
	echo "[ $i of ${TOTAL} ]"
	./scan.sh ${IMAGE}
done

echo '------'
cd "${SCANLOGS_DIR}/combined/"
find . -name "*.json" | while read -r LOGFILE; do cat "${LOGFILE}" | jq -r '.Results[] | select(.Vulnerabilities) | .Vulnerabilities[] | .Severity + "~" + .PkgName + "~Fixed in " + .FixedVersion + "~" + .VulnerabilityID' | grep -v -E '^(MEDIUM|LOW|UNKNOWN)' | wc -l | xargs -I {} echo "{} ${LOGFILE}"; done | sort -rn
echo '------'

echo "Finished"
