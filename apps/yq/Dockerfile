## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:3fa12464f1313ee6c634acc679d3b3fd4ef8c8412eb1ccf2e8720012ae514d91

# set version label
ARG VERSION
ARG TARGETARCH
USER root
COPY container-test.yaml /container-test.yaml

RUN echo "**** install app ****" && \
  python3 -m venv /app/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    yq=="${VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app
