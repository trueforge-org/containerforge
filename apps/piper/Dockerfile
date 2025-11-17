
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV TMPDIR="/run/piper-temp"

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
