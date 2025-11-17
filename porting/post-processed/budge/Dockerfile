
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV BUDGE_DATABASE=/config/budge.db \
    S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    python3 && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    nodejs \
    npm \
    sqlite && \
  echo "**** install budge ****" && \
  mkdir -p /app/www/public && \
  curl -o \
    /tmp/budge.tar.gz -L \
    "https://github.com/linuxserver/budge/archive/${VERSION}.tar.gz" && \
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
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config
