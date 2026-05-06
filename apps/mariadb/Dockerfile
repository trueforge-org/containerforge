
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:0ddd714cd20cf10c41ba76066e9579cfc785579f1b801c3656b4bc0ceb151442

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
