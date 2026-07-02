

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d
ARG TARGETARCH
ARG VENDOR
ARG VERSION

ENV    NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (${VENDOR})"

USER root
WORKDIR /app

RUN \
    apt-get update \
    && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        uuid-runtime \
        xmlstarlet \
    && \
    curl -fsSL -o /tmp/plex.deb \
        "https://downloads.plex.tv/plex-media-server-new/${VERSION}/debian/plexmediaserver_${VERSION}_${TARGETARCH}.deb" \
    && \
    dpkg -i /tmp/plex.deb \
    && chmod -R 755 "${PLEX_MEDIA_SERVER_HOME}" \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /etc/default/plexmediaserver /tmp/* /var/lib/apt/lists/* /var/tmp/


USER apps
COPY --chmod=0755 . /
WORKDIR /config
