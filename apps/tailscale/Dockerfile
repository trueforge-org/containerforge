ARG VERSION=v1.98.10

FROM tailscale/tailscale:${VERSION}@sha256:cdf5612ded5be1344f1a704b8c5e53496db97376bb533e5e15f141e48bf60cc0 AS tailscale
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:2b0e3e5b096604f1f054edb5746abb22e6180ac4ae923d4f797ab697d4401eb0

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iproute2 \
        iptables \
    && rm /usr/sbin/iptables && ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables \
    && rm /usr/sbin/ip6tables && ln -s /usr/sbin/ip6tables-legacy /usr/sbin/ip6tables \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/tailscale
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=tailscale /usr/local/bin/containerboot /usr/local/bin/containerboot

RUN mkdir /tailscale && ln -s /usr/local/bin/containerboot /tailscale/run.sh

VOLUME ["/var/lib/tailscale"]

CMD ["/usr/local/bin/containerboot"]
