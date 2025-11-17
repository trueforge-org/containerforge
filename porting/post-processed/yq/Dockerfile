
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    python3 && \
  echo "**** install app ****" && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}"
