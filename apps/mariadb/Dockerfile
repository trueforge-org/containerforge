
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a

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
