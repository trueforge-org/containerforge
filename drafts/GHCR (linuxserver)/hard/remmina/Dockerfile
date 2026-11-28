
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# BLOCKED (plan section 10): Remmina is a GTK client and needs an X display. The display stack (Xvfb plus a VNC or web bridge) is not chosen, and its package names are UNVERIFIED on resolute. Do not build until it is.
ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config/xdg \
  XDG_CACHE_HOME=/tmp/cache \
  XDG_RUNTIME_DIR=/tmp/runtime

# Pinned to the Ubuntu 26.04 package version (apt pin, plan section 1).
RUN echo "*** Installing Remmina ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    remmina=${VERSION}+dfsg-0ubuntu0.26.04.2 \
    remmina-plugin-rdp \
    remmina-plugin-vnc \
    librsvg2-common && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/remmina && \
  cp /usr/share/doc/remmina/copyright /usr/share/licenses/remmina/LICENSE && \
  echo "*** Cleaning Up ***" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# UNVERIFIED: /usr/share/doc/remmina/copyright is the standard dpkg location; confirm it exists in the package.
# UNVERIFIED: the display stack packages (for example xvfb, x11vnc, novnc) are not listed yet. Add them once section 10 is decided.

USER apps
COPY --chmod=0755 . /

# EXPOSE is left open until the display stack is decided (plan section 4).

VOLUME /config
