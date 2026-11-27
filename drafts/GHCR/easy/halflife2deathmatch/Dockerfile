# UNVERIFIED: no digest is recorded in the repo for this tag. Pin one once the tag is confirmed as published.
ARG VERSION
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION
USER root

# The base image ships its own /start.sh (SteamCMD app update logic). The COPY below replaces it,
# so keep a copy under another name for start.sh to call.
RUN install -m 0755 /start.sh /usr/local/bin/steamcmd-base.sh

USER apps
COPY --chmod=0755 . /

VOLUME /config

CMD ["/start.sh"]
