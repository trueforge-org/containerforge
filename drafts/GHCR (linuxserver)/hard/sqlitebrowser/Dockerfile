
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION=3.13.1
ARG TARGETARCH
# UNVERIFIED: no upstream checksum or signature for the AppImage. Fill in the self-computed sha256 on the first download. Empty fails closed.
ARG APPIMAGE_SHA256=
USER root

ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config/xdg \
  XDG_CACHE_HOME=/tmp/cache \
  XDG_RUNTIME_DIR=/tmp/runtime

# BLOCKED (plan section 10): sqlitebrowser is a Qt GUI and needs an X display. The display stack is not chosen.
RUN echo "*** Installing DB Browser for SQLite ***" && \
  if [ "$TARGETARCH" = "amd64" ]; then \
    curl -fsSL -o \
      /tmp/sqlitebrowser.AppImage \
      "https://github.com/sqlitebrowser/sqlitebrowser/releases/download/v${VERSION}/DB.Browser.for.SQLite-v${VERSION}-x86.64-v2.AppImage" && \
    echo "${APPIMAGE_SHA256}  /tmp/sqlitebrowser.AppImage" | sha256sum -c - && \
    chmod +x /tmp/sqlitebrowser.AppImage && \
    cd /tmp && /tmp/sqlitebrowser.AppImage --appimage-extract && \
    mv /tmp/squashfs-root /app/sqlitebrowser && \
    chown -R apps:apps /app/sqlitebrowser && chmod -R 755 /app/sqlitebrowser && \
    # UNVERIFIED: AppRun is the AppImage entry point, and the link goes to AppRun so Qt libraries load
    ln -s /app/sqlitebrowser/AppRun /usr/local/bin/sqlitebrowser ; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends sqlitebrowser=${VERSION}-1 && \
    ln -s /usr/bin/sqlitebrowser /usr/local/bin/sqlitebrowser && \
    # UNVERIFIED: package binary name and version match on arm64 (confirm with dpkg -L)
    apt-get clean && rm -rf /var/lib/apt/lists/* ; \
  else \
    echo "unsupported arch: $TARGETARCH" && exit 1 ; \
  fi && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/sqlitebrowser && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/sqlitebrowser.AppImage /var/tmp/* /tmp/*

# UNVERIFIED: the license files (LICENSE-MPL-2.0 and LICENSE-GPL-3.0) are not copied yet. Copy them from the source repo once the file names are checked.
# UNVERIFIED: Qt runtime libraries missing on resolute. Install only what the first run reports missing, and record each one.

USER apps
COPY --chmod=0755 . /

# EXPOSE is left open until the display stack is decided (plan section 10).

VOLUME /config
