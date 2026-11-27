FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NODE_ENV=production \
    NPM_CONFIG_CACHE=/tmp/npm-cache

# UNVERIFIED: client build on the base Node version (upstream uses node:20); no client lockfile checked
RUN \
  echo "**** install flame ****" && \
  mkdir -p /app/flame && \
  curl -fL -o \
    /tmp/flame.tar.gz \
    "https://github.com/pawelmalak/flame/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/flame.tar.gz -C \
    /app/flame --strip-components=1 && \
  cd /app/flame && \
  npm install --omit=dev && \
  cd /app/flame/client && \
  npm install && \
  npm run build && \
  cd /app/flame && \
  mkdir -p public && \
  mv client/build/* public/ && \
  rm -rf client && \
  ln -s /config/data /app/flame/data && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/flame && \
  cp /app/flame/LICENSE.md /usr/share/licenses/flame/LICENSE && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5005
VOLUME /config
