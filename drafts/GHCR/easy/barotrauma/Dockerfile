# UNVERIFIED digest: pin with `docker buildx imagetools inspect` once the published tag is checked.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp
EXPOSE 27016/udp

VOLUME /config
