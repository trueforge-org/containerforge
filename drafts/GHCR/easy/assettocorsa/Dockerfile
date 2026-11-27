FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: no digest pin yet. Add the steamcmd image digest once it is confirmed.

ARG VERSION

# Steam app 302550 (Assetto Corsa dedicated server). UNVERIFIED: taken from the TrueCharts chart values, not confirmed on Steam.
ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  GAME_ID=302550 \
  VALIDATE=false

USER apps
COPY --chmod=0755 . /

VOLUME /config
