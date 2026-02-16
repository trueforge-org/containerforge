
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00750811fb5c6481942d0f9903fa012e5c221ebb8ddd261024fb72fecf456429

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
