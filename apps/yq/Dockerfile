## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.7@sha256:1b4e02f5ae67a789aaf0f3d0d059a6eee7da28a9998c7018070edff055aff72a

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
