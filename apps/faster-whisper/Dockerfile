
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d0392caa927c7c5f3d2e75b31098faa3cebad8d7c311fe7dfd0d074270418422

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
  && pip3 install -U --no-cache-dir \
    pip \
    wheel && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    git+https://github.com/rhasspy/wyoming-faster-whisper@v${VERSION} && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential \
    git \
    python3-dev && \
  cp /etc/ssl/certs/ca-certificates.crt /etc/ca-certificates.crt && \
  chmod 644 /etc/ca-certificates.crt && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

USER apps
COPY ./ /

VOLUME /config

EXPOSE 10300
