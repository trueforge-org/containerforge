
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME=/config

# UNVERIFIED: the apt package `qdirstat` on ubuntu 26.04 (amd64 and arm64) and its version. Pin the resolved version and check it against VERSION.
# UNVERIFIED: if the package is absent or too old, build from the source archive in a separate stage instead.
RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    novnc \
    qdirstat \
    websockify \
    x11vnc \
    xvfb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /


EXPOSE 5800 5900

VOLUME /config

WORKDIR /config
