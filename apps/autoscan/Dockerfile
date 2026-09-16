

FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:a299b521c05afacfd1ce985e61fd282232805e988a8b2a731f62e8bfbc8eccf5 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:fe30ffe7e0841a2e19f3a508d9ae62b594feada6829d9b78d21cd534a8e8ac8b

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY --chmod=0755 . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
