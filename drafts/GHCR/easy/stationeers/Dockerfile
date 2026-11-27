# Base is the ContainerForge steamcmd image (apps/steamcmd). Tag must match VERSION in docker-bake.hcl.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  STEAM_APP_IDS=600760 \
  STEAM_INSTALL_DIR=/config/stationeers \
  TZ=Etc/UTC

USER apps
COPY --chmod=0755 . /

# The launcher lives in scripts/ so it does not replace the base /start.sh (the SteamCMD wrapper).
ENTRYPOINT ["/scripts/stationeers-start.sh"]

VOLUME /config
