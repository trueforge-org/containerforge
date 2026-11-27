# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# UNVERIFIED: the library list is taken from the upstream wrapper. Trim it with `ldd` on the downloaded daemon.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libglib2.0-0 \
        libgl1 \
        libxcb1 \
        libxdamage1 \
        libxext6 \
        libxshmfence1 \
        libxxf86vm1 \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# The Dropbox daemon is proprietary and is NOT part of the image. start.sh downloads it on first start.
RUN install -d /usr/share/licenses/dropbox-by-otherguy && \
    printf '%s\n' "This image does not contain the Dropbox daemon. start.sh downloads it at first start under Dropbox's terms." \
        > /usr/share/licenses/dropbox-by-otherguy/README

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 17500

VOLUME /config

CMD ["/start.sh"]
