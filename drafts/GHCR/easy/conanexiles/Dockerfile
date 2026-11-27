FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: the digest of this tag is not in the plan. Read it from the registry and pin it before merge.

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

# start.sh replaces the base /start.sh. The base /usr/local/bin/steamcmd wrapper still execs /start.sh (see plan section 10).
# The root-owned /start.sh is overwritten by COPY . / below.
EXPOSE 7777/udp 7778/udp 27015/udp
VOLUME /config

USER apps
COPY --chmod=0755 . /
