

FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:b068d80b5f6d257316b4f66ac5b2099f8ebbcd780855da5e80e4bccb3e9b18d8 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:24efb13c405c262ba2d501640e0a70e0454439ed722125055b11814ff49323db

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY --chmod=0755 . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
