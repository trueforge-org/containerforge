
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87

# set version label
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3306

VOLUME /config

WORKDIR /config
