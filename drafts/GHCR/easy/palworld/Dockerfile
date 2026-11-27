# UNVERIFIED: add @sha256:<digest> from `docker buildx imagetools inspect ghcr.io/trueforge-org/steamcmd:20180105-5build1` once the image is published.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

USER root

# The COPY below replaces /start.sh, which the base /usr/local/bin/steamcmd wrapper execs.
# Keep the base SteamCMD wrapper under a different name so the install step can still call it.
RUN cp /start.sh /usr/local/share/steamcmd/steamcmd-init.sh && \
  chmod 0755 /usr/local/share/steamcmd/steamcmd-init.sh && \
  chown apps:apps /usr/local/share/steamcmd/steamcmd-init.sh

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config

USER apps
COPY --chmod=0755 . /

VOLUME /config
