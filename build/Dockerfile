FROM ghcr.io/aquasecurity/trivy:latest

ARG DOCKER_GID

# SETUP USER
ARG USER_NAME=appuser
ARG USER_ID=9001
ARG GROUP_NAME=appuser
ARG GROUP_ID=9001
RUN addgroup -g ${GROUP_ID} ${GROUP_NAME}
RUN adduser -u ${USER_ID} -S ${USER_NAME} -G ${GROUP_NAME}

# ALLOW USER TO RUN ACCESS DOCKER SOCK
RUN addgroup -g ${DOCKER_GID} docker
RUN addgroup ${USER_NAME} docker

# FIX PERMISSIONS FOR TRIVY CACHE
RUN mkdir /.cache && \
	chown -R ${USER_ID}:${GROUP_ID} /.cache

# INSTALL DOCKER
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/docker

# INSTALL JQ
RUN apk add --no-cache jq

# ADD TIMEZONE SUPPORT
RUN apk add --no-cache tzdata

# SETUP SUPERCRONIC FOR NON-ROOT USER
ENV SUPERCRONIC_VERSION="v0.2.1"
RUN wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
	chmod 755 /usr/local/bin/supercronic
COPY --chmod=644 ./crontab /crontab
RUN supercronic -json -test /crontab

# COPY SCRIPTS
COPY --chmod=755 ./scripts /scripts

# RUN AS USER
USER ${USER_ID}

ENTRYPOINT [ "/scripts/entrypoint.sh" ]
CMD [ "run" ]
