# UNVERIFIED: the Ubuntu krusader package version, the display stack package names and arm64 availability are not yet checked.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG PACKAGE_VERSION

USER root

ENV HOME=/config DATA_DIR=/config/krusader

# hadolint ignore=DL3008,DL3015
RUN test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "krusader=${PACKAGE_VERSION}" \
        xvfb \
        fluxbox \
        x11vnc \
        novnc \
        websockify \
        dbus-x11 \
        fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=0755 . /

USER apps
WORKDIR /config

EXPOSE 8080
VOLUME /config

CMD ["/start.sh"]
