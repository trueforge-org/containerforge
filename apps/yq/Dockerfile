## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:0859da470a5092cf1bdec06d87165ec6eebd7d490682b89035f450db869223fb

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
