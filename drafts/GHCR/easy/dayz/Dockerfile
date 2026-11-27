FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: the digest of this tag is not in the plan. Read it from the registry and pin it before merge.

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

EXPOSE 2302/udp 27016/udp
VOLUME /config

USER apps
COPY --chmod=0755 . /
