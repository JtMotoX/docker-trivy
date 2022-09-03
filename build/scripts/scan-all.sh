#!/bin/sh

cd "$(dirname "$0")"

echo "Scanning images of all running containers . . ."

IMAGES="$(docker ps --format "{{.Image}}")"
TOTAL="$(echo "${IMAGES}" | wc -l)"

i=0
echo "${IMAGES}" | while read -r IMAGE; do
	i=$(( i + 1 ))
	echo "[ $i of ${TOTAL} ]"
	./scan.sh ${IMAGE}
done
