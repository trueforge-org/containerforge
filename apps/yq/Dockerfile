## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:28879e692c9ef5264f2bc23dc0cb2ff1402c276b2126309e00eb097ee5ebc1a1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "**** install app ****" && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app
