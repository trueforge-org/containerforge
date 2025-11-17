


FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV LANG='en_US.UTF-8'

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    build-base && \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache \
    ffmpeg \
    mediainfo && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/medusa && \
  curl -o \
    /tmp/medusa.tar.gz -L \
    "https://github.com/pymedusa/Medusa/archive/v${VERSION}.tar.gz" && \
  tar xf /tmp/medusa.tar.gz -C \
    /app/medusa --strip-components=1 && \
  cd /app/medusa && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    setuptools && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# copy local files
USER apps
COPY . /



# ports and volumes
EXPOSE 8081
VOLUME /config
