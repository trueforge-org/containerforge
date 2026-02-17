
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        php-gd \
        php-mysql \
        php-pgsql \
        php-sqlite3 && \
    rm -rf /var/lib/apt/lists/* && \
    echo "**** install librespeed ****" && \
    mkdir -p \
        /app/www/public && \
    (curl -fL -o \
        /tmp/librespeed.tar.gz \
        "https://github.com/librespeed/speedtest/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
        /tmp/librespeed.tar.gz \
        "https://github.com/librespeed/speedtest/archive/refs/tags/v${VERSION}.tar.gz") && \
    tar xf \
        /tmp/librespeed.tar.gz -C \
        /app/www/public --strip-components=1 && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
