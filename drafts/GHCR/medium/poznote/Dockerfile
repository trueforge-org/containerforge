FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    nginx \
    php8.5-fpm \
    php8.5-sqlite3 \
    php8.5-curl \
    php8.5-mbstring \
    php8.5-zip \
    php8.5-xml \
    supervisor && \
  echo "**** fetch poznote ****" && \
  curl -fL -o \
    /tmp/poznote.tar.gz \
    "https://github.com/timothepoznanski/poznote/archive/refs/tags/${VERSION}.tar.gz" && \
  # UNVERIFIED: upstream publishes no checksum for the tag tarball; record the sha256 computed here at first build.
  mkdir -p \
    /tmp/poznote \
    /app/poznote && \
  tar xf \
    /tmp/poznote.tar.gz -C \
    /tmp/poznote --strip-components=1 && \
  cp -r \
    /tmp/poznote/src/. \
    /app/poznote/ && \
  echo "**** create data symlink (state lives in /config) ****" && \
  rm -rf /app/poznote/data && \
  ln -s /config/data /app/poznote/data && \
  echo "**** install license ****" && \
  install -D -m 0644 \
    /tmp/poznote/LICENCE \
    /usr/share/licenses/poznote/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files (etc/ holds nginx, php-fpm and supervisord config for unprivileged runs)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
