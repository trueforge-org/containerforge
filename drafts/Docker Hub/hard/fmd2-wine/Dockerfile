# UNVERIFIED: pin the kasmvnc base digest here once it is read from ghcr.io.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:7e96ef6465ad32c153f71fdff80fa4e2cb8fdfce1ab79dd269f08c7647505275

ARG VERSION
ARG TARGETARCH

ENV HOME=/config \
    WINEPREFIX=/config/.wine \
    WINEARCH=win64 \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    WINEDEBUG=-all \
    XDG_CACHE_HOME=/tmp/cache

USER root

# The FMD2 Windows build runs under Wine and ships for x86_64 only.
RUN [ "$TARGETARCH" = "amd64" ] || { echo "fmd2-wine is amd64 only" >&2; exit 1; }

# UNVERIFIED: wine version. Upstream pins wine64=9.0~repack-4build3 on noble;
# the version in the 26.04 base is not checked, so the package is not pinned here.
RUN \
  echo "**** install wine ****" && \
  dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    wine64 \
    wine32:i386 \
    p7zip-full \
    winbind \
    cabextract && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** install FMD2 ${VERSION} ****" && \
  curl -fsSL -o /tmp/fmd2.7z \
    "https://github.com/dazedcat19/FMD2/releases/download/${VERSION}/fmd_${VERSION}_x86_64-win64.7z" && \
  # UNVERIFIED: no checksum is published for this release; add a sha256 check once one is recorded.
  mkdir -p /app/FMD2 && \
  7z x -y -o/app/FMD2 /tmp/fmd2.7z && \
  rm -f /tmp/fmd2.7z && \
  echo "**** move writable data out of /app ****" && \
  mkdir -p /usr/share/fmd2-defaults && \
  for d in userdata lua data; do \
    if [ -d "/app/FMD2/$d" ]; then \
      mv "/app/FMD2/$d" "/usr/share/fmd2-defaults/$d"; \
    else \
      mkdir -p "/usr/share/fmd2-defaults/$d"; \
    fi && \
    ln -s "/config/FMD2/$d" "/app/FMD2/$d"; \
  done && \
  echo "**** licenses ****" && \
  mkdir -p /usr/share/licenses/fmd2-wine && \
  find /app/FMD2 -maxdepth 1 -type f \( -iname 'license*' -o -iname 'readme*' -o -iname 'copying*' \) \
    -exec cp {} /usr/share/licenses/fmd2-wine/ \; && \
  echo "**** downloads mount point ****" && \
  mkdir -p /downloads && \
  chown apps:apps /downloads && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3000 3001
VOLUME /config
