FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    XDG_RUNTIME_DIR=/tmp/.XDG

# UNVERIFIED: headless CLI only. The upstream GUI (jlesage/baseimage-gui, Alpine) is not ported; see start.sh.
# UNVERIFIED: handbrake-cli version from the Ubuntu archive; pin it against VERSION once apt-cache policy is checked.
RUN \
  echo "**** install handbrake cli ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    handbrake-cli && \
  echo "**** ship licence ****" && \
  mkdir -p /usr/share/licenses/handbrake && \
  cp /usr/share/doc/handbrake-cli/copyright /usr/share/licenses/handbrake/copyright && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# volumes
VOLUME /config
VOLUME /storage
VOLUME /output

WORKDIR /config
