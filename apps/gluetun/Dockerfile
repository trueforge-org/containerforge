FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:acbb7d5055789d4e4da6343772b3ce7b6215b13f726252c4dd59f3027f8b6eb1 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/qdm12/gluetun.git /src/gluetun && \
    cd /src/gluetun && \
    go build -trimpath -ldflags="-s -w" -o /usr/local/bin/gluetun cmd/gluetun/main.go

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

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
COPY --chmod=0755 container-test.yaml /container-test.yaml
ENTRYPOINT ["/usr/local/bin/gluetun"]
