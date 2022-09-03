## Instructions
1. Determine the host docker gid: `stat -c '%g' /var/run/docker.sock`
1. Update the [./.env](./.env) file with the DOCKER_GID
