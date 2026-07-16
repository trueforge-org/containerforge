FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:2b01c636b280837a6f650162e0639b7c1169939f860a2fef069eea6d92fc4e93 AS builder

ARG VERSION

USER root
RUN git clone --depth 1 --branch "${VERSION}" https://github.com/qdm12/gluetun.git /src/gluetun && \
    cd /src/gluetun && \
    go build -trimpath -ldflags="-s -w" -o /usr/local/bin/gluetun cmd/gluetun/main.go

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:68e4815a37ff22f61b5f6bcd8f3ae25804632b5fe0f77ad11f6ddf0a8173aa60

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
