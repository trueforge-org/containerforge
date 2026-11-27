# UNVERIFIED: base tag and digest copied from the plan (ghcr.io manifest read 2026-11-24); re-check before building.
# Inherits KasmVNC (openbox, 3000/3001, /config as HOME) from apps/kasmvnc.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27

ARG VERSION
ARG TARGETARCH
# SHA-256 of OpenAudible_${VERSION}_x86_64.deb, from https://openaudible.org/swt_version.json
ARG OPENAUDIBLE_SHA256=f75b4eb391382a48b02be2ab6adc2ff40f23ed5bdf531383a92f283b1db569bf
USER root

ENV DEBIAN_FRONTEND=noninteractive \
    OA_PACKAGING=docker \
    OA_KIOSK=true \
    oa_internal_browser=true \
    KASM_AUDIO_ENABLED=1 \
    KASM_AUDIO_QUALITY=medium \
    START_PULSEAUDIO=1 \
    XDG_CURRENT_DESKTOP=XFCE \
    XDG_CACHE_HOME=/tmp/.cache

# Only the amd64 .deb is pinned here. The vendor manifest lists an aarch64 installer script, not a .deb (UNVERIFIED on arm64).
RUN \
  echo "**** guard architecture ****" && \
  test "${TARGETARCH}" = "amd64" || { echo "OpenAudible is only packaged for amd64" >&2; exit 1; }

# The base's /start.sh is replaced by COPY . / below, so keep a copy for start.sh to chain to.
RUN \
  echo "**** keep kasmvnc start script ****" && \
  cp -p /start.sh /usr/local/bin/kasmvnc-start.sh && \
  chmod 0755 /usr/local/bin/kasmvnc-start.sh

RUN \
  echo "**** install openaudible ****" && \
  apt-get update && \
  curl -fL -o /tmp/openaudible.deb \
    "https://github.com/openaudible/openaudible/releases/download/v${VERSION}/OpenAudible_${VERSION}_x86_64.deb" && \
  echo "${OPENAUDIBLE_SHA256}  /tmp/openaudible.deb" | sha256sum -c - && \
  apt-get install -y --no-install-recommends \
    /tmp/openaudible.deb \
    alsa-utils \
    ca-certificates \
    libgtk-3-bin \
    libwebkit2gtk-4.1-0 \
    thunar && \
  echo "**** check installed version and files ****" && \
  dpkg-query -W -f='${Package} ${Version}\n' openaudible && \
  dpkg-query -W -f='${Version}\n' openaudible | grep -q "^${VERSION}" && \
  dpkg -L openaudible && \
  echo "**** licence notice ****" && \
  mkdir -p /usr/share/licenses/openaudible && \
  { cp -a /usr/share/doc/openaudible/. /usr/share/licenses/openaudible/ 2>/dev/null || true; } && \
  printf '%s\n' "OpenAudible is proprietary software. See https://openaudible.org/ for its licence terms." \
    > /usr/share/licenses/openaudible/NOTICE && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# add local files (defaults/autostart replaces the base's autostart, start.sh chains to kasmvnc-start.sh)
USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001
