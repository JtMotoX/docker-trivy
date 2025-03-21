FROM ghcr.io/aquasecurity/trivy:latest

# SETUP USER
ARG USER_NAME=appuser
ARG USER_ID=9001
ARG GROUP_NAME=appuser
ARG GROUP_ID=9001
RUN addgroup -g ${GROUP_ID} ${GROUP_NAME}
RUN adduser -u ${USER_ID} -S ${USER_NAME} -G ${GROUP_NAME}

ENV SCANLOGS_DIR="/var/log/scan-logs"

# FIX PERMISSIONS FOR TRIVY CACHE
RUN install -o ${USER_ID} -g ${GROUP_ID} -d /.cache

# INSTALL DOCKER
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/docker

# INSTALL JQ
RUN apk add --no-cache jq

# ADD TIMEZONE SUPPORT
RUN apk add --no-cache tzdata

# SETUP SUPERCRONIC FOR NON-ROOT USER
ADD --chmod=755 https://github.com/aptible/supercronic/releases/latest/download/supercronic-linux-amd64 /usr/local/bin/supercronic
RUN install -m 644 -o ${USER_ID} -g ${GROUP_ID} /dev/null /crontab
RUN supercronic -no-reap -json -test /crontab

# ALLOW USER TO RUN ACCESS DOCKER SOCK
RUN apk add --no-cache sudo
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:SETENV: /scripts/list-images.sh" >> /etc/sudoers.d/${USER_NAME}
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:SETENV: /scripts/trivy-scan.sh" >> /etc/sudoers.d/${USER_NAME}
RUN cat /etc/sudoers.d/${USER_NAME}

# COPY SCRIPTS
COPY --chmod=755 --chown=root:root ./scripts /scripts

# RUN AS USER
USER ${USER_ID}

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "run" ]
