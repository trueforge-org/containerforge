## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:ded45532b707cd6a04d07ec3be3feb9a128b6ee053eb6eb349c8c85eeeefbc9b

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
