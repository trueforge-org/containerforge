# UNVERIFIED: the steamcmd base tag is taken from the plan. Add an @sha256 digest once ghcr.io/trueforge-org/steamcmd is published.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

USER root

# The base image ships its own /start.sh (the SteamCMD wrapper). Keep a copy so start.sh below can call it.
RUN cp /start.sh /usr/local/share/steamcmd/steamcmd-init.sh && \
    chmod 0755 /usr/local/share/steamcmd/steamcmd-init.sh && \
    chown apps:apps /usr/local/share/steamcmd/steamcmd-init.sh

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    STEAM_INSTALL_DIR=/config/pavlovvr \
    STEAM_APP_IDS=622970

USER apps
COPY --chmod=0755 . /

# UNVERIFIED: ports are not confirmed yet (draft lists 7777/udp, 8803/udp, 27015/udp).
VOLUME /config
