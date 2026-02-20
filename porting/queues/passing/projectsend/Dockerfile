
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    php8.3-bcmath \
    php8.3-bz2 \
    php8.3-cli \
    php8.3-xml \
    php8.3-gd \
    php8.3-mysql \
    php8.3-gmp \
    php8.3-mysql \
    php8.3-sqlite3 \
    php-apcu \
    php-memcached \
    php8.3-soap \
    php8.3-xml && \
  echo "**** install projectsend ****" && \
  mkdir -p /app/www/public && \
  curl -fso \
    /tmp/projectsend.zip -L \
    "https://github.com/projectsend/projectsend/releases/download/${VERSION}/projectsend-${VERSION}.zip" || \
  curl -fso \
    /tmp/projectsend.zip -L \
    "https://github.com/projectsend/projectsend/releases/download/${VERSION}/projectsend.zip" && \
  unzip \
    /tmp/projectsend.zip -d \
    /app/www/public && \
  mv /app/www/public/upload /defaults/ && \
  echo "**** download default lang files ****" && \
  mkdir -p /defaults/lang && \
  curl -fso \
    /defaults/lang/en.mo -L \
    "https://raw.githubusercontent.com/projectsend/projectsend/refs/heads/develop/templates/default/lang/en.mo" && \
  curl -fso \
    /defaults/lang/en.po -L \
    "https://raw.githubusercontent.com/projectsend/projectsend/refs/heads/develop/templates/default/lang/en.po" && \
  echo "**** cleanup ****" && \
    rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
