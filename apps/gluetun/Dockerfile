FROM ghcr.io/trueforge-org/golang:rolling@sha256:c41cbcc9a0c9ecf82304696ed8de4352a4a819c12a2c7d4e3b1f3ce527999e7a AS builder

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
HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=3 CMD ["/usr/local/bin/gluetun", "healthcheck"]

USER apps
COPY container-test.yaml /container-test.yaml
ENTRYPOINT ["/usr/local/bin/gluetun"]
