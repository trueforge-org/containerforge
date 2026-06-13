
FROM ghcr.io/trueforge-org/python-node:3.14.6@sha256:2a6210017e3f1d7b59413c8c331a761f73b9f257fd0e4fd06bc0ef9e376af124

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG WIKIJS_RELEASE

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
  if [ -z "${WIKIJS_RELEASE:-}" ]; then \
    WIKIJS_RELEASE=$(curl -sI -L "https://github.com/Requarks/wiki/releases/latest" | awk -F/ '/^location:/ {print $NF}' | tr -d '\r'); \
  fi && \
  (curl -fL -o \
    /tmp/wiki.tar.gz \
    "https://github.com/Requarks/wiki/releases/download/${WIKIJS_RELEASE}/wiki-js.tar.gz" || curl -fL -o \
    /tmp/wiki.tar.gz \
    "https://github.com/Requarks/wiki/releases/latest/download/wiki-js.tar.gz") && \
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
