# syntax=docker/dockerfile:1

ARG VERSION
FROM docker.io/tailscale/tailscale:v${VERSION} AS tailscale

FROM ghcr.io/trueforge-org/ubuntu:24.04
USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iptables \
        iproute2 \
        ip6tables && \
    rm -rf /var/lib/apt/lists/*

USER nobody:nogroup

# Copy the binaries from the Tailscale image
COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/tailscale
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/tailscaled
COPY --from=tailscale /usr/local/bin/containerboot /usr/local/bin/containerboot

WORKDIR /config
