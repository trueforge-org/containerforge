FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV XDG_CACHE_HOME=/tmp/cache \
    XDG_RUNTIME_DIR=/tmp/xdg \
    DISPLAY=:99

# UNVERIFIED: package availability of the display stack on 26.04 (xvfb, x11vnc, novnc, websockify, fluxbox) and arm64 for rapid-photo-downloader
RUN \
  echo "**** install rapid photo downloader ${VERSION} and display stack ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    rapid-photo-downloader=0.9.37-0ubuntu4.1 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    dbus-x11 \
    fonts-dejavu-core && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
