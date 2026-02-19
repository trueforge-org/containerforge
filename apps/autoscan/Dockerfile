

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:b4224a2abd8322eafc4c63ea85ad1cf5afe5d7e133d4ef5ee8a5409b4a22ef2a as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

COPY container-test.yaml /container-test.yaml
USER apps

COPY . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
