

FROM ghcr.io/trueforge-org/golang:1.25.7@sha256:e6bde907a745d8f7a3efccf46d172631dde8e8d857a189bfcab634ef1ea2fd64 as builder
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN mkdir /autoscan && \
    wget -O - "https://github.com/Cloudbox/autoscan/archive/v${VERSION}.tar.gz" | tar xzf - -C "/autoscan" --strip-components=1 && \
    cd /autoscan && \
    go build -o autoscan ./cmd/autoscan && \
    chmod 755 "/autoscan/autoscan"

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:128e24cac8026983dcd46413896d467cc1ffae9d933164f758866e7519eae606

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps:apps

COPY . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
