ARG VERSION=v1.98.8

FROM tailscale/tailscale:${VERSION}@sha256:d54b2e6a9c09f0e5ec52e82b9ad4af3d446b54a7c08075e92f11c39dd410105f AS tailscale
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

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
