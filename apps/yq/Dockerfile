## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d9b5d12c8e22d9b84df211da15c73e7e2b36441675f00bba2c706f93526c602b

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
