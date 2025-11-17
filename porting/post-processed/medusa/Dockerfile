
FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/trueforge-org/ubuntu:24.4

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
    mediainfo \
    python3 && \
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
    pip \
    setuptools \
    wheel && \
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


# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8081
VOLUME /config
