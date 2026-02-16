
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get add --no-cache \
    php84-bcmath \
    php84-bz2 \
    php84-cli \
    php84-dom \
    php84-gd \
    php84-gettext \
    php84-gmp \
    php84-mysqli \
    php84-pdo \
    php84-pdo_dblib \
    php84-pdo_mysql \
    php84-pecl-apcu \
    php84-pecl-memcached \
    php84-soap \
    php84-xmlreader && \
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
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
