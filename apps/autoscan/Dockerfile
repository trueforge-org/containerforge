

FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:670dd56d3e2b5c3d96e734fed538bb65c8c6ee76e629f48087769edb2b8c7047 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5cb91be3e738ebbd91b616dc8ec0dd21d25980038f39d6b941f30a0b106d1ecf

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps

COPY --chmod=0755 . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
