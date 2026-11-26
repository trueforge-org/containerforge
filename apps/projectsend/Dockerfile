
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

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
