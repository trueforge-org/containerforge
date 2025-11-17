
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV APPRISE_CONFIG_DIR=/config \
  APPRISE_ATTACH_DIR=/attachments \
  APPRISE_ATTACH_SIZE=0

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    cargo \
    build-base \
    libffi-dev \
    openssl-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    uwsgi \
    uwsgi-python && \
  mkdir -p /app && \
  curl -o \
    /tmp/apprise-api.tar.gz -L \
    "https://github.com/caronc/apprise-api/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/apprise-api.tar.gz -C \
    /app/ --strip-components=1 && \
  echo "**** install pip packages ****" && \
  cd /app && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.cargo \
    /tmp/*

# copy local files
USER apps
COPY . /

EXPOSE 8000
