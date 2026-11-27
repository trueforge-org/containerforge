# UNVERIFIED: the base digest is not pinned yet. Read it from the registry and pin it, do not guess.
ARG VERSION=20180105-5build1
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

ENV TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 27016/udp

ENTRYPOINT ["/start.sh"]
