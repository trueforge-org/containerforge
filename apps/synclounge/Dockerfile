FROM ghcr.io/trueforge-org/node:24.15.0@sha256:c7c4a7a0c399c025cd2677db6215cf530d7e18e51b8461a0b449bcac85ccbf3b

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
