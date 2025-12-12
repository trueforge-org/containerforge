## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6a1f7016a76387e56144ba2467a8488c7871aed21e473006bd1cce4ea5df211e

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
