#!/bin/sh

if [ "$1" = "run" ]; then
	# echo 'sleeping . . .'; tail -f /dev/null

	echo "Starting cron"
	supercronic /crontab

	echo "Oops! Looks like cron stopped."
	exit 1
fi

exec "$@"
