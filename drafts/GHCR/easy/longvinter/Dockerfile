FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: the steamcmd base tag is a placeholder for this draft. The digest is not in the plan. Confirm both before merge.

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

EXPOSE 27016/udp
VOLUME /config

USER apps
COPY --chmod=0755 . /
