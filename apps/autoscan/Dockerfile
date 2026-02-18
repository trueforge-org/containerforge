

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:74ea31a8f0af085d1bf920c5b10b75349effddab995cc4c2e2cc401a93b16839 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
