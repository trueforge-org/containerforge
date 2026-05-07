
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:f7d559cef2b714762b919fffffabb8892824a30cb61e3df293dcad6851a29a3b

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
COPY --chmod=0755 . /
COPY ./ /

VOLUME /config

EXPOSE 10200
