# UNVERIFIED: pin a digest once ghcr.io/trueforge-org/steamcmd is published.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION

ENV HOME=/config \
    XDG_DATA_HOME=/config

COPY --chmod=0755 . /

USER apps
