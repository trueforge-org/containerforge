ARG VERSION=v1.104.2

FROM tailscale/tailscale:${VERSION}@sha256:b11583ad2e93e4671128538c88cf11f460444a5d7e449311dd1933a400ab849d AS tailscale
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:fbb8b286bdadd3cda896e800061cc867ad228255b76c968de072f2bf16794598

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
