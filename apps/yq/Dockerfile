## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.7@sha256:74252ae048ecabddaafe9eeb2cd08f8c9ea9ee0c09458a0f41c93d170d6ea9da

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
