
# UNVERIFIED: the published steamcmd image digest is not confirmed; pin @sha256 from the registry at build time.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
ENV HOME=/config

USER apps
COPY --chmod=0755 . /

VOLUME /config
