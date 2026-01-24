## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:3664bd10fe22328f1b7d6d1002a074b6bbfc78b7688200388230f49190d622e2

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
