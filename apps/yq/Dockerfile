## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:77449580f12ca47641798a11e38291c1e30b532818ea7809078c3fa6e9bfc4df

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
