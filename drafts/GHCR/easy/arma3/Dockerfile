# Base: ContainerForge steamcmd (amd64 only, same as the game). Tag = apps/steamcmd VERSION.
# Digest UNVERIFIED: pin once the base image is published.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

# Steam app 233780 is installed at first start (see start.sh). Game version is not pinned.
# Server ports (chart lists 2302 to 2306 game/query/steam ports; UDP per chart mainudp, see settings.yaml).
EXPOSE 2302/udp 2303/udp 2304/udp 2305/udp 2306/udp

USER apps
COPY --chmod=0755 . /

VOLUME /config
