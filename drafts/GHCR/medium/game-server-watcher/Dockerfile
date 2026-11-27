FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS buildstage

# set version label
ARG VERSION
USER root

ENV NPM_CONFIG_CACHE=/tmp/npm

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3 && \
  echo "**** fetch source code ****" && \
  # no upstream checksum is published; the tag is pinned to commit 2010cd81 (UNVERIFIED that the tarball matches it)
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/gsw.tar.gz \
    "https://github.com/a-sync/game-server-watcher/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/gsw.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** install and build ****" && \
  # git is needed for the optional github: dependency (erlpack); arm64 build UNVERIFIED
  cd /tmp/src && \
  npm ci --include=dev && \
  npm run build && \
  npm prune --omit=dev && \
  mkdir -p /app && \
  mv /tmp/src /app/game-server-watcher && \
  echo "**** license ****" && \
  install -D /app/game-server-watcher/LICENSE.md /usr/share/licenses/game-server-watcher/LICENSE.md && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add game-server-watcher and license
COPY --from=buildstage /app/game-server-watcher /app/game-server-watcher
COPY --from=buildstage /usr/share/licenses/game-server-watcher /usr/share/licenses/game-server-watcher

ENV NODE_ENV=production

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
