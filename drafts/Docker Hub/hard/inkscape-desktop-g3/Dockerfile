FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG PACKAGE_VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config/.config \
  XDG_CACHE_HOME=/tmp/.cache \
  XDG_RUNTIME_DIR=/tmp/runtime \
  DISPLAY=:1 \
  NO_AT_BRIDGE=1 \
  _INKSCAPE_GC=disable \
  VNC_PORT=5901 \
  NOVNC_PORT=6901 \
  VNC_RESOLUTION=1360x768 \
  VNC_COL_DEPTH=24

# Version guard: the Ubuntu package version must match VERSION (for example 1.4.3-0ubuntu2 for 1.4.3).
# UNVERIFIED: package names for the xfce parts and tigervnc/novnc/websockify on resolute, and /usr/share/doc/inkscape/copyright.
RUN \
  echo "**** install desktop packages ****" && \
  test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    inkscape="${PACKAGE_VERSION}" \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    python3-websockify \
    xfce4-session \
    xfwm4 \
    xfce4-panel \
    xfdesktop4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    xauth \
    fonts-dejavu-core \
    ca-certificates && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/inkscape-desktop-g3 && \
  cp /usr/share/doc/inkscape/copyright /usr/share/licenses/inkscape-desktop-g3/inkscape-copyright && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5901 6901
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
