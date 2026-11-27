# UNVERIFIED: pin the base digest once the steamcmd image digest is confirmed
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    STEAM_APP_IDS=258550 \
    STEAM_INSTALL_DIR=/config/steamapps

# Keep the base SteamCMD bootstrap script, because this app replaces /start.sh.
USER root
RUN cp /start.sh /usr/local/bin/steamcmd-base.sh && \
    chmod 0755 /usr/local/bin/steamcmd-base.sh && \
    mkdir -p /config/steamapps && \
    chown -R apps:apps /config

COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

EXPOSE 28015/udp
VOLUME /config
ENTRYPOINT ["/start.sh"]
