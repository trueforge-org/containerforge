# UNVERIFIED: the base tag is not confirmed. No digest is pinned yet. Set VERSION in docker-bake.hcl.
ARG VERSION=UNVERIFIED
FROM ghcr.io/trueforge-org/steamcmd:${VERSION}

ARG VERSION

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/scripts/survivethenights-start.sh"]
