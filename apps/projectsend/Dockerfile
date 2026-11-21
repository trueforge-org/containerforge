
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    php8.5-bcmath \
    php8.5-bz2 \
    php8.5-cli \
    php8.5-xml \
    php8.5-gd \
    php8.5-mysql \
    php8.5-gmp \
    php8.5-mysql \
    php8.5-sqlite3 \
    php-apcu \
    php-memcached \
    php8.5-soap \
    php8.5-xml && \
  echo "**** install projectsend ****" && \
  mkdir -p /app/www/public && \
  curl -fso \
    /tmp/projectsend.zip -L \
    "https://github.com/projectsend/projectsend/releases/download/${VERSION}/projectsend-${VERSION#v}.zip" && \
  unzip \
    /tmp/projectsend.zip -d \
    /app/www/public && \
  echo "**** cleanup ****" && \
    rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
