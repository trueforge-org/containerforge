## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00bb62757540babe6b6ed56afef7816c6ab762f584fdfc0d0961cd53ea1de812

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
