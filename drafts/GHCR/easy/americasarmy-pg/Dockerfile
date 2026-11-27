FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: the digest of this tag is not in the plan. Read it from the registry and pin it before merge.

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config \
    TMPDIR=/tmp

# 7778/udp (game port from -port=7778) is not added until its protocol is confirmed.
EXPOSE 8778/udp 27015/udp
VOLUME /config

USER apps
COPY --chmod=0755 . /
