
FROM ghcr.io/trueforge-org/python-node:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV BUDGE_DATABASE=/config/budge.db \
    S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    python3 \
    python-is-python3 && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    sqlite3 && \
  echo "**** install budge ****" && \
  mkdir -p /app/www/public && \
  (curl -fL -o \
    /tmp/budge.tar.gz \
    "https://github.com/linuxserver/budge/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/budge.tar.gz \
    "https://github.com/linuxserver/budge/archive/refs/tags/v${VERSION}.tar.gz") && \
  tar xf \
    /tmp/budge.tar.gz -C \
    /app/www/public/ --strip-components=1 && \
  echo "**** install backend ****" && \
  cd /app/www/public/backend && \
  npm install && \
  npm run build && \
  npm prune --omit=dev && \
  echo "**** install ynab importer ****" && \
  cd /app/www/public/ynab && \
  npm install && \
  echo "**** install frontend ****" && \
  cd /app/www/public/frontend && \
  npm install && \
  npm run build && \
  npm prune --omit=dev && \
  echo "**** overlay-fs bug workaround ****" && \
  mv /app/www/public/frontend/node_modules /app/www/public/frontend/node_modules-tmp && \
  mv /app/www/public/backend/node_modules /app/www/public/backend/node_modules-tmp && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential python3-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
