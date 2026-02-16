## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.3@sha256:ce429d498a8b592f7495c3cd2ac98d31c56d4ffaf00cacbb49e418494e25c626

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
