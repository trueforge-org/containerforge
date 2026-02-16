

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:9553c58d3700b7322b23a4a4cc1e4e33d04d7787625fd27c9baeb51f93cf0be5 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5d05227fca161b90936494534d014201795165beb84d5f1aced98565f7c6655e

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps:apps

COPY . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
