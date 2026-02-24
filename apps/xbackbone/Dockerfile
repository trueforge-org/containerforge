
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:1c874769d7dc656030d189c30532396d444ab56a283f2828480b4c8a06359ee8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    php8.3-ftp \
    php8.3-cli \
    php8.3-gd \
    php8.3-intl \
    php8.3-ldap \
    php8.3-mysql \
    php8.3-sqlite3 \
    php8.3-tokenizer && \
  echo "**** install xbackbone ****" && \
    mkdir -p /app/www/public && \
  curl -o \
    /tmp/xbackbone.zip -L \
    "https://github.com/SergiX44/XBackBone/releases/download/${VERSION}/release-v${VERSION}.zip" && \
  unzip -q -o /tmp/xbackbone.zip -d /app/www/public/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
