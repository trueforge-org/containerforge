

FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:3fd10a391f8008f64aca8b98a86eca4def2680c3bd692c3db54b60b5b50e61e3 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:68e4815a37ff22f61b5f6bcd8f3ae25804632b5fe0f77ad11f6ddf0a8173aa60

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY --chmod=0755 . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
