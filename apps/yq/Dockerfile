## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.5@sha256:c1237b4ee242c9d67a1bae2611ab92f45e8c39da8835a974e4dd49d43077c353

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
