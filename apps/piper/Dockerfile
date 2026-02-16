
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:3ba383a203ccb7bca70a25d7a34d422dd3ab48053023dd3ca67f51bca3ef3955

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN pip3 install -U --no-cache-dir \
    pip \
    wheel && \
  pip3 install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
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
