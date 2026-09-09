
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1888fc219883c47800b75c40a586266ebb7362f9a13f697dbe894fb777a299bf

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    php8.5-cli \
    php8.5-gd \
    php8.5-intl \
    php8.5-ldap \
    php8.5-mysql \
    php8.5-sqlite3 && \
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
