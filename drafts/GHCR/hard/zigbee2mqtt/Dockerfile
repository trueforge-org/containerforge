FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV NODE_ENV=production

# UNVERIFIED: python-node Node major must fall in upstream engines.node (^22.2.0 || ^24 || <=26.2); check before first build.
# UNVERIFIED: no published checksum for the source archive; add a sha256 check once it is computed from a first download.
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python-is-python3 && \
  echo "**** install zigbee2mqtt ${VERSION} ****" && \
  mkdir -p /app /config && \
  curl -fL -o \
    /tmp/zigbee2mqtt.tar.gz \
    "https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/zigbee2mqtt.tar.gz -C \
    /app --strip-components=1 && \
  cd /app && \
  echo "**** pin pnpm to the version in packageManager ****" && \
  PNPM_VERSION="$(node -p "require('./package.json').packageManager.split('@')[1]")" && \
  npm install -g "pnpm@${PNPM_VERSION}" && \
  echo "**** install dependencies and build dist ****" && \
  pnpm install --frozen-lockfile && \
  pnpm exec tsc && \
  mkdir -p dist && \
  echo "${VERSION}" > dist/.hash && \
  pnpm prune --prod && \
  echo "**** ship licence and default configuration ****" && \
  mkdir -p /usr/share/licenses/zigbee2mqtt /defaults && \
  cp /app/LICENSE /usr/share/licenses/zigbee2mqtt/LICENSE && \
  cp /app/data/configuration.example.yaml /defaults/configuration.example.yaml && \
  echo "**** cleanup ****" && \
  pnpm store prune || true && \
  npm cache clean --force && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential && \
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
EXPOSE 8080
VOLUME /config

WORKDIR /config
