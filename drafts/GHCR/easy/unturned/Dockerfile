# UNVERIFIED: the steamcmd base digest is not in the plan. Pin the sha256 digest at build time.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ARG VENDOR

ENV HOME=/config \
    TMPDIR=/tmp

# Replaces the base /start.sh (plan section 10). Rename if that matters.
COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/start.sh"]

EXPOSE 27015/udp

VOLUME /config
