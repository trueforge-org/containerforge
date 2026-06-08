FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:a77358c4adde98184f31ad3ddd611d01ca9cbd4e5f6b1267b9b0f69c95bf9563 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/qdm12/gluetun.git /src/gluetun && \
    cd /src/gluetun && \
    go build -trimpath -ldflags="-s -w" -o /usr/local/bin/gluetun cmd/gluetun/main.go

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:c21fcd861c5eccd1dec9c7b9a88647fc3a22585c3d7cf77ba48129844e7a584b

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iptables \
        openvpn && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=builder /usr/local/bin/gluetun /usr/local/bin/gluetun

ENV VPN_SERVICE_PROVIDER=pia \
    VPN_TYPE=openvpn \
    VPN_INTERFACE=tun0

EXPOSE 8000/tcp 8888/tcp 8388/tcp 8388/udp

USER apps
COPY --chmod=0755 . /
ENTRYPOINT ["/usr/local/bin/gluetun"]
