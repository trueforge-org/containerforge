
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
ENV MYSQL_DIR="/config"
ENV DATADIR="$MYSQL_DIR/databases"

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        logrotate \
        mariadb-server \
        mariadb-backup \
        mariadb-client \
        mariadb-common \
        mariadb-server-core && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        $HOME/.cache

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3306

VOLUME /config

WORKDIR /config
