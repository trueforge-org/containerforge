

FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:ffbd498a6e856cfb87d5172b067b2bddc9c3aff05e3229f6cce3a8ba8cbbba3b as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:ea16b55109312b5eda59cf3cdd576c10979b7532e0a9561de068b9679794ea33

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY --chmod=0755 . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
