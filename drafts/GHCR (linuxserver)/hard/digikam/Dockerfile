FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
  XDG_CACHE_HOME=/tmp/cache \
  TZ=Etc/UTC

# The AppImage is x86-64 only (upstream drops aarch64). Fails on other arches.
# UNVERIFIED: no checksum is published by the mirror. The detached .sig is fetched
# but NOT verified: the KDE signing key fingerprint is UNVERIFIED (plan section 4).
RUN echo "*** Installing digiKam ***" && \
  [ "$TARGETARCH" = "amd64" ] || { echo "digikam: amd64 only" >&2; exit 1; } && \
  curl -fL -o /tmp/digikam.appimage \
    "https://mirrors.mit.edu/kde/stable/digikam/${VERSION}/digiKam-${VERSION}-Qt6-x86-64.appimage" && \
  curl -fL -o /tmp/digikam.appimage.sig \
    "https://mirrors.mit.edu/kde/stable/digikam/${VERSION}/digiKam-${VERSION}-Qt6-x86-64.appimage.sig" && \
  chmod +x /tmp/digikam.appimage && \
  cd /tmp && \
  ./digikam.appimage --appimage-extract && \
  mv /tmp/squashfs-root /app/digikam && \
  echo "*** Installing license ***" && \
  LIC="$(find /app/digikam -maxdepth 3 \( -iname 'COPYING*' -o -iname 'LICENSE*' \) | head -n 1)" && \
  test -n "$LIC" && \
  install -Dm644 "$LIC" /usr/share/licenses/digikam/LICENSE && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/digikam.appimage /tmp/digikam.appimage.sig && \
  chown -R apps:apps /app/digikam && chmod -R 755 /app/digikam

# UNVERIFIED: the display stack (Xvfb plus a remote-desktop server on 3001) is not
# chosen yet (plan section 10, blocker 1). Upstream also installs chromium, caja and
# mariadb-server; they are left out until a test shows a missing dependency.

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3001
VOLUME /config
