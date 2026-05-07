## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:f7d559cef2b714762b919fffffabb8892824a30cb61e3df293dcad6851a29a3b

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
