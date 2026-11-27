# UNVERIFIED: Steam app id 294420 is not confirmed (plan.md section 1). Do not build until it is.
# Base: apps/steamcmd provides SteamCMD and the 32-bit libraries. The registry digest is not in the plan, so pin it at build time.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

USER root

ENV \
  HOME=/config \
  STEAM_APP_IDS=294420 \
  STEAM_INSTALL_DIR=/config/steamapps

# start.sh replaces the base /start.sh. The base /usr/local/bin/steamcmd wrapper calls that file, but this image does not use the wrapper.
USER apps
COPY --chmod=0755 . /

VOLUME /config
