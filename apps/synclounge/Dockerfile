FROM ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/app"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install SyncLounge ****" && \
  npm install -g --omit=dev synclounge@"$VERSION" && \
  npm prune --omit=dev && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


WORKDIR /config
VOLUME /config
