## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.15.1@sha256:fcc611b0d03ab808bdce505d2d2524c941ec5d2314ef3eb0b63c43d22bd6a2b2

# set version label
ARG VERSION
ARG TARGETARCH
USER root
COPY --chmod=0755 . /

RUN echo "**** install app ****" && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app
