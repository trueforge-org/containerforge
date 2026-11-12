
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f5810a8898e3c4010e9609799c2cc0ef871d42a7637fbdd77f2c62c1e67b495c

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        php-cli \
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
    mkdir -p /config/www && \
    cp -a /app/www/public /config/www/public && \
    rm -rf /app/www/public && \
    ln -s /config/www/public /app/www/public && \
    chown -R apps:apps /config && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
