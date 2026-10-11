
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:c298a5e065ea46d0280a6f0e4b696c549d169a280e63ee6b49791865753112ca

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
