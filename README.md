# docker-trivy

## Description
This will perform a vulnerability scan of all images of currently running containers.  The schedule is defined in the [crontab](/build/crontab) file. It is recommended to have the log files pushed into a logging tool such as Splunk for analysis and alerting.

## Instructions
1. Determine the host docker gid: `stat -c '%g' /var/run/docker.sock`
1. Update the [.env](/.env) file with the DOCKER_GID
1. Run `docker-compose down && docker-compose up --build -d && docker-compose logs -f`
1. Press `CTRL+C` to stop tailing the container logs (container will continue to run)
1. The scan logs will be stored in the [scan-logs](/scan-logs) directory
