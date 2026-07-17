
FROM ghcr.io/trueforge-org/python-node:3.14.6@sha256:fc75c629fd59f99513f0a111799067431ccd0a55ecc14f6295e3421b2952a9b0

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
  echo "**** pin npm to v10 (npm v11 omits optional peer deps required by budge) ****" && \
  npm install -g npm@10 && \
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
  echo "**** bump bcrypt to v6 (v5 ships node-addon-api incompatible with Node 24, breaks arm64 source build) ****" && \
  npm pkg set "dependencies.bcrypt=^6.0.0" && \
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


# ports and volumes
EXPOSE 5000
VOLUME /config

WORKDIR /config
