# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG APT_VERSION=1.37.0+debian-4

# UNVERIFIED: the Debian copyright path is assumed; confirm with `ls /usr/share/doc/aria2/` on the first build.
USER root

# hadolint ignore=DL3008,DL3015
RUN test "${APT_VERSION%%+*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "aria2=${APT_VERSION}" \
    && aria2c --version > /tmp/aria2-version.txt \
    && grep -q "aria2 version ${VERSION}" /tmp/aria2-version.txt \
    && rm -f /tmp/aria2-version.txt \
    && mkdir -p /usr/share/licenses/aria2 \
    && cp /usr/share/doc/aria2/copyright /usr/share/licenses/aria2/copyright \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV HOME=/config \
    RPC_PORT=6800 \
    LISTEN_PORT=6888

RUN install -d -o apps -g apps /config /downloads

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 6800 6888 6888/udp
VOLUME /config
VOLUME /downloads
