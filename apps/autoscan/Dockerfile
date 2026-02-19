

FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:c41cbcc9a0c9ecf82304696ed8de4352a4a819c12a2c7d4e3b1f3ce527999e7a as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

EXPOSE 3030
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="3030/tcp,3030/udp"

USER apps
COPY container-test.yaml /container-test.yaml

COPY . /

COPY --from=builder /autoscan/autoscan /app/autoscan

WORKDIR /config
