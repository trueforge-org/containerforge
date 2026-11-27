# UNVERIFIED: the steamcmd base tag. Add an @sha256 digest once ghcr.io/trueforge-org/steamcmd is published.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    TMPDIR=/tmp

USER apps
# start.sh replaces the base image's /start.sh (the SteamCMD wrapper). This image runs SteamCMD directly.
COPY --chmod=0755 . /

VOLUME /config

CMD ["/start.sh"]
