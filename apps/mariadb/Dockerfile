
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:205c6561352214872c61edea4909f29afe9be1eee6c61430ce627ca757c137ed

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
