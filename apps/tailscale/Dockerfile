ARG VERSION=v1.102.5

FROM tailscale/tailscale:${VERSION}@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065 AS tailscale
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5491a2f46a8408f4085d5b92ff59358bafd56e7f26058b30347bfdefa568ed8a

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
