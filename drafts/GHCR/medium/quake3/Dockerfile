FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: the ioquake3 apt package version on ubuntu 26.04 (amd64 and arm64) is not confirmed.
# VERSION in docker-bake.hcl is a placeholder, so this step fails until it is pinned.
# UNVERIFIED: the copyright file path under /usr/share/doc/ioquake3 is assumed from Debian packaging conventions.
# Game pak files are NOT installed here; they are supplied by the user into /config.
RUN test "${VERSION}" != "UNVERIFIED" && \
    apt-get update && \
    apt-get install -y --no-install-recommends "ioquake3=${VERSION}" && \
    mkdir -p /usr/share/licenses/quake3 /config && \
    cp /usr/share/doc/ioquake3/copyright /usr/share/licenses/quake3/copyright && \
    chown apps:apps /config && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config \
    Q3_PORT=27960 \
    Q3_MAP=q3dm0

USER apps
COPY --chmod=0755 . /

# The chart declares the game port as udp, and the upstream image has no EXPOSE.
EXPOSE 27960/udp

VOLUME /config
