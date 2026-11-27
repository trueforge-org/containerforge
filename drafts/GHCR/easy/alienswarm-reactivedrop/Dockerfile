
# UNVERIFIED: digest not pinned. Read the digest of this tag from the registry and pin it before merge.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ARG VENDOR

ENV \
  TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp 27015/tcp

VOLUME /config
