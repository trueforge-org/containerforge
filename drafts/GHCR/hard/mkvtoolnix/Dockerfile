# UNVERIFIED: VERSION and PACKAGE_VERSION are placeholders until the apt package for resolute is checked.
# UNVERIFIED: the arm64 apt line, the GUI stack package names and the apt key fingerprint are not yet confirmed.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION
ARG TARGETARCH

USER root

ENV HOME=/config DISPLAY=:0 XDG_CACHE_HOME=/tmp/cache

# Add the official MKVToolNix apt repo (resolute = Ubuntu 26.04), install the pinned packages, then remove the repo file.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget && \
    mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/gpg-pub-moritzbunkus.gpg https://mkvtoolnix.download/gpg-pub-moritzbunkus.gpg && \
    echo "deb [arch=${TARGETARCH} signed-by=/etc/apt/keyrings/gpg-pub-moritzbunkus.gpg] https://mkvtoolnix.download/ubuntu/ resolute main" \
        > /etc/apt/sources.list.d/mkvtoolnix.download.list && \
    apt-get update && \
    test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get install -y --no-install-recommends \
        "mkvtoolnix=${PACKAGE_VERSION}" \
        "mkvtoolnix-gui=${PACKAGE_VERSION}" \
        xvfb \
        x11vnc \
        novnc \
        websockify \
    && apt-get purge -y wget \
    && rm -f /etc/apt/sources.list.d/mkvtoolnix.download.list \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 . /

USER apps

EXPOSE 5800 5900
VOLUME /config

CMD ["/start.sh"]
