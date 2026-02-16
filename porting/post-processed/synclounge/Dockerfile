FROM ghcr.io/trueforge-org/node:22.22.0

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/app"

RUN \
  echo "**** install build packages ****" && \
  apt-get add --no-cache --virtual=build-dependencies \
    build-base && \
  echo "**** install SyncLounge ****" && \
  npm install -g --omit=dev synclounge@"$VERSION" && \
  npm prune --omit=dev && \
  echo "**** cleanup ****" && \
  apt-get del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY . /


WORKDIR /config
VOLUME /config
