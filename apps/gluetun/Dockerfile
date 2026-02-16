FROM ghcr.io/trueforge-org/golang:rolling@sha256:be0a42e1af759466bd249b5ce04c288e8beab4df14ac634fc9aa6db04bbe8b03 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/qdm12/gluetun.git /src/gluetun && \
    cd /src/gluetun && \
    go build -trimpath -ldflags="-s -w" -o /usr/local/bin/gluetun cmd/gluetun/main.go

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:128e24cac8026983dcd46413896d467cc1ffae9d933164f758866e7519eae606

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
HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=3 CMD ["/usr/local/bin/gluetun", "healthcheck"]

USER apps:apps
ENTRYPOINT ["/usr/local/bin/gluetun"]
