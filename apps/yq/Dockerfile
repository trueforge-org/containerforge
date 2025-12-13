## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:9339a4781b93a9baa1cd0378613939fc7fedcd032f0852fc7680688ab655f533

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
