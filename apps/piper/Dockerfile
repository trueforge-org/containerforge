
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:ec0d5db35e9cb896aa56dba7cacc1a97dede19debe52c217ed044e7a32f27536

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
