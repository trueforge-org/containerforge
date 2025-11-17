## TODO: pin version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:56c028d92c9c7e5d29c1265fd0b615c9fbc4995cf5f6ef6007393c3030b4b749

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/app"
WORKDIR /app

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base && \
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

