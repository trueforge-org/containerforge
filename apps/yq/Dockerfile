## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:2eeeff0873bb716c998dbcbbe7f6bf04f37a653398ff79d366890fa93fd072b8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "**** install app ****" && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app
