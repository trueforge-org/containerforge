
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1

# set version label
ARG VERSION
ARG PACKAGE_VERSION
ARG TARGETARCH
USER root

# environment variables
ENV MYSQL_DIR="/config"
ENV DATADIR="$MYSQL_DIR/databases"

RUN \
    echo "**** install runtime packages ****" && \
    package_version="${PACKAGE_VERSION#*:}" && \
    test "${package_version%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        logrotate \
        "mariadb-server=${PACKAGE_VERSION}" \
        "mariadb-backup=${PACKAGE_VERSION}" \
        "mariadb-client=${PACKAGE_VERSION}" \
        "mariadb-common=${PACKAGE_VERSION}" \
        "mariadb-server-core=${PACKAGE_VERSION}" && \
    mkdir -p /run/mysqld && \
    chown apps:apps /run/mysqld && \
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
