
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV S6_STAGE2_HOOK=/init-hook
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    build-base \
    libffi-dev \
    libxml2-dev \
    libzen-dev \
    python3-dev && \
  apk add  -U --update --no-cache \
    libjpeg \
    libxslt \
    python3 && \
  mkdir -p /app/kometa && \
  curl -o \
    /tmp/kometa.tar.gz -L \
    "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/kometa.tar.gz -C \
    /app/kometa --strip-components=1 && \
  cd /app/kometa && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config

ENTRYPOINT ["/init-kometa"]
