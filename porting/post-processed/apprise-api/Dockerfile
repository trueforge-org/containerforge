
FROM ghcr.io/trueforge-org/ubuntu:24.4

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
    openssl-dev \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    python3 \
    uwsgi \
    uwsgi-python && \
  mkdir -p /app/apprise-api && \
  curl -o \
    /tmp/apprise-api.tar.gz -L \
    "https://github.com/caronc/apprise-api/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/apprise-api.tar.gz -C \
    /app/apprise-api/ --strip-components=1 && \
  echo "**** install pip packages ****" && \
  cd /app/apprise-api && \
  python3 -m venv /lsiopy && \
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
