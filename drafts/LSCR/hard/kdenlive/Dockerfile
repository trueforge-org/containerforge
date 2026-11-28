# UNVERIFIED: the plan cited ubuntu digest f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...; the repo's ubuntu:26.04 siblings use f01a4295... (used here).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# kdenlive is pinned to the Ubuntu archive version; VERSION must match the pin (bake VERSION).
# UNVERIFIED package names: melt, frei0r-plugins, ffmpeg (plan section 4).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      "kdenlive=4:${VERSION}-0ubuntu1.1" \
      melt \
      frei0r-plugins \
      ffmpeg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/*

# BLOCKED (plan section 10): display and web streaming layer not chosen yet.
# The upstream selkies base is Arch-only and cannot be used.

ENV HOME=/config \
    TITLE=Kdenlive \
    NO_GAMEPAD=true

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3001
VOLUME /config
