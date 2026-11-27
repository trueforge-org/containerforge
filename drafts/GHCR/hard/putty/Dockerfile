
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME=/config

# UNVERIFIED: the apt package `putty` on ubuntu 26.04 and its version. Pin the resolved version and check it against VERSION (see apps/valkey).
RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    novnc \
    putty \
    websockify \
    x11vnc \
    xvfb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*
# UNVERIFIED: the PuTTY licence (MIT). Check /usr/share/doc/putty/copyright in the built image and copy it to /usr/share/licenses/putty/ if it is missing.

USER apps
COPY --chmod=0755 . /


EXPOSE 5800 5900

VOLUME /config

WORKDIR /config
