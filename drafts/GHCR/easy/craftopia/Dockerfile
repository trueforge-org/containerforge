# UNVERIFIED: the steamcmd base digest is not in the plan. Pin the sha256 digest at build time.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ARG VENDOR

ENV TMPDIR=/tmp

# UNVERIFIED open question (plan section 10): this replaces the base /start.sh,
# which the base /usr/local/bin/steamcmd execs. Rename it if that matters.
COPY --chmod=0755 start.sh /start.sh

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/start.sh"]

EXPOSE 8787/tcp 8787/udp

VOLUME /config
