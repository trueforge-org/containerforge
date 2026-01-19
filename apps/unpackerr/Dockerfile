

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:afda48b06fbfbd284a91a99ec069d72accfe94ee427ff64604811edc5b049667
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
