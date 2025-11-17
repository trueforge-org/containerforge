
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/app"
WORKDIR /app

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    nodejs && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    git \
    npm && \
  echo "**** install SyncLounge ****" && \
  npm install -g --omit=dev synclounge@"$VERSION" && \
  npm prune --omit=dev && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY . /

