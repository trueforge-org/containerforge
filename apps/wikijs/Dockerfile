
FROM ghcr.io/trueforge-org/python-node:3.15.1@sha256:3ae479227e69d69b2ddb0f94bf12ef785f8f88d2bbde3032ca02f701b336064f

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/app"
ENV NODE_ENV="production"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
  apt-get install -y --no-install-recommends \
    git \
    nodejs \
    npm \
    openssh-client && \
  echo "**** install wiki.js ****" && \
  mkdir -p /app/wiki && \
  (curl -fL -o \
    /tmp/wiki.tar.gz \
    "https://github.com/Requarks/wiki/releases/download/v${VERSION}/wiki-js.tar.gz" || curl -fL -o \
    /tmp/wiki.tar.gz \
    "https://github.com/Requarks/wiki/releases/download/${VERSION}/wiki-js.tar.gz") && \
  tar xf \
    /tmp/wiki.tar.gz -C \
    /app/wiki/ && \
  cd /app/wiki && \
  npm rebuild sqlite3 && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
