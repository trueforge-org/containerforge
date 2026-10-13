ARG VERSION=v1.104.1

FROM tailscale/tailscale:${VERSION}@sha256:87c55d6be56ad85b3d8bceca5f87f73de288c609131460dd1be1874c250cc41d AS tailscale
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:ea16b55109312b5eda59cf3cdd576c10979b7532e0a9561de068b9679794ea33

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
