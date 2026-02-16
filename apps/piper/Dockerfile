
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00750811fb5c6481942d0f9903fa012e5c221ebb8ddd261024fb72fecf456429

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
