#!/bin/sh

set -e
cd "$(dirname "$0")"

# VERIFY USER AND GROUP
getent passwd "${OWNER_UID}" >/dev/null 2>&1 || { echo "ERROR: User with UID '${OWNER_UID}' does not exist"; exit 1; }
getent group "${OWNER_GID}" >/dev/null 2>&1 || { echo "ERROR: Group with GID '${OWNER_GID}' does not exist"; exit 1; }

# REMOVE EXISTING FILE IF EXISTS
rm -f "${COMBINED_TMPFILE}"

# SCAN THE IMAGE
if ! trivy image ${IMAGE} --scanners vuln --ignore-unfixed -f json -o "${COMBINED_TMPFILE}"; then
	echo "ERROR: Failed to scan ${IMAGE}"
	rm -f "${COMBINED_TMPFILE}"
	exit 1
fi

# CHANGE OWNER OF THE FILE
chown "${OWNER_UID}:${OWNER_GID}" "${COMBINED_TMPFILE}"
