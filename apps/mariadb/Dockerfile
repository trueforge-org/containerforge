
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

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
COPY container-test.yaml /container-test.yaml
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3306

VOLUME /config

WORKDIR /config
