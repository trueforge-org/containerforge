
# Build stage: fetch the upstream source at the tag and build client and server.
# UNVERIFIED: the upstream Dockerfile is Alpine (musl) and runs as root. This is a rewrite of the install steps for the ubuntu-based python-node image.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 && \
  echo "**** fetch source at tag v${VERSION} ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o \
    /tmp/abs.tar.gz \
    "https://github.com/advplyr/audiobookshelf/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/abs.tar.gz -C \
    /tmp/src --strip-components=1 && \
  echo "**** build client ****" && \
  cd /tmp/src/client && \
  npm ci && \
  npm run generate && \
  echo "**** build server ****" && \
  cd /tmp/src && \
  npm ci --include=dev --ignore-scripts && \
  npm run build:server && \
  npm ci --omit=dev && \
  echo "**** stage runtime tree ****" && \
  mkdir -p \
    /app/audiobookshelf/client && \
  cp -a /tmp/src/dist-server /app/audiobookshelf/ && \
  cp -a /tmp/src/client/dist /app/audiobookshelf/client/ && \
  cp -a /tmp/src/node_modules /app/audiobookshelf/ && \
  cp -a /tmp/src/package.json /app/audiobookshelf/ && \
  install -D -m 0644 \
    /tmp/src/LICENSE \
    /usr/share/licenses/audiobookshelf/LICENSE && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /root/.npm \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

# /app stays read-only at runtime. State goes to /config, caches to /tmp.
ENV NODE_ENV=production \
    PORT=8000 \
    CONFIG_PATH=/config \
    METADATA_PATH=/config/metadata \
    SOURCE=docker \
    HOME=/config \
    XDG_CACHE_HOME=/tmp

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    tzdata && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

COPY --from=build /app/audiobookshelf/ /app/audiobookshelf/
COPY --from=build /usr/share/licenses/audiobookshelf/ /usr/share/licenses/audiobookshelf/

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
# UNVERIFIED: port 8000 is a deliberate change from the upstream PORT=80, which a rootless user cannot bind.
EXPOSE 8000
VOLUME /config

WORKDIR /app/audiobookshelf
