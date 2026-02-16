
FROM ghcr.io/trueforge-org/python:3.13.12

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
  apt-get -U --update --no-cache add --virtual=build-dependencies \
    build-base && \
  apt-get add --no-cache \
    git \
    nodejs \
    npm \
    openssh && \
  echo "**** install wiki.js ****" && \
  mkdir -p /app/wiki && \
  if [ -z ${WIKIJS_RELEASE} ]; then \
    WIKIJS_RELEASE=$(curl -sX GET "https://api.github.com/repos/Requarks/wiki/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/wiki.tar.gz -L \
    "https://github.com/Requarks/wiki/releases/download/${WIKIJS_RELEASE}/wiki-js.tar.gz" && \
  tar xf \
    /tmp/wiki.tar.gz -C \
    /app/wiki/ && \
  cd /app/wiki && \
  npm rebuild sqlite3 && \
  echo "**** cleanup ****" && \
  apt-get del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000

VOLUME /config

WORKDIR /config
