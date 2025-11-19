
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6119b5ecab933bfd4ceb9c7e56b8c93379b830d6a5af0aa9cb7b014e1078be8f

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN mkdir -p /app/cfpy && python3 -m venv /app/cfpy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    piper-tts \
    "wyoming-piper==${VERSION}" && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

USER apps
COPY ./ /

VOLUME /config

EXPOSE 10200
