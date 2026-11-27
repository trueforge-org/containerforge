
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-sqlite3 \
    php8.5-xml \
    sqlite3 \
    unzip && \
  echo "**** fetch baikal ${VERSION} ****" && \
  curl -fL -o /tmp/baikal.zip \
    "https://github.com/sabre-io/Baikal/releases/download/${VERSION}/baikal-${VERSION}.zip" && \
  unzip -q /tmp/baikal.zip -d /tmp/baikal-src && \
  mkdir -p /app && \
  mv /tmp/baikal-src/baikal /app/www && \
  echo "**** keep shipped config and data for seeding, then link to /config ****" && \
  mkdir -p /defaults/baikal-skel && \
  cp -a /app/www/config /defaults/baikal-skel/config && \
  cp -a /app/www/Specific /defaults/baikal-skel/Specific && \
  rm -rf /app/www/config /app/www/Specific && \
  ln -s /config/config /app/www/config && \
  ln -s /config/Specific /app/www/Specific && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/baikal && \
  find /app/www -maxdepth 1 -iname 'LICENSE*' -exec cp {} /usr/share/licenses/baikal/ \; && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# copy local files
USER apps
ENV HOME=/config \
    TMPDIR=/tmp
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
