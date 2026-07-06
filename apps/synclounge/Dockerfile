FROM ghcr.io/trueforge-org/node:24.18.0@sha256:6ec4fab2b7ac2090590b454edf431acec72749608cd3c60990bbad03a19f07ac

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
