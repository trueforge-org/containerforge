FROM ghcr.io/trueforge-org/node:22.22.0

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV PORT=3000

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsass-dev \
    npm && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    nodejs && \
  echo "**** install raneto ****" && \
  mkdir -p \
    /app/raneto && \
  (curl -fL -o \
    /tmp/raneto-src.tar.gz \
    "https://github.com/ryanlelek/Raneto/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
    /tmp/raneto-src.tar.gz \
    "https://github.com/ryanlelek/Raneto/archive/refs/tags/v${VERSION}.tar.gz") && \
  tar xf \
    /tmp/raneto-src.tar.gz -C \
    /app/raneto --strip-components=1 && \
  echo "**** install raneto node dev modules and build ****" && \
  cd /app/raneto && \
  sed -i \
    's/upgradeInsecureRequests: \[\]/upgradeInsecureRequests: null/g' \
    app/index.js && \
  npm install --omit=dev && \
  mkdir sessions && \
  rm -f config/config.js && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.npm \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
