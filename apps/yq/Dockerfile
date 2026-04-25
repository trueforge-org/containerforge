## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.13@sha256:d90e00c1ba6abf16c8d68d5e898657109371cd601270e3a3ae5b32782fe1cc15

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
