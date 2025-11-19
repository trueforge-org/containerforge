

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:d7637b3330e77450c56e9682790fd79f8c63124dff1593086c05d74d0179a39f
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# TODO readd chromaprint
RUN echo "test"

COPY . /

USER apps:apps
WORKDIR /config
