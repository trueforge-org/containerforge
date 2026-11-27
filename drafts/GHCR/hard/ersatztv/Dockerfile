FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  ETV_CONFIG_FOLDER=/config \
  ETV_TRANSCODE_FOLDER=/tmp/transcode \
  ETV_DISABLE_VULKAN=1 \
  FONTCONFIG_PATH=/etc/fonts \
  XDG_CACHE_HOME=/tmp/.cache

# UNVERIFIED: the apt ffmpeg build may lack the NVENC or VAAPI support that the upstream ffmpeg image provides.
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libva-drm2 && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no checksum is published, and the tarball's top-level layout is not confirmed.
RUN echo "*** Installing ErsatzTV ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) ETV_ARCH=x64 ;; \
    arm64) ETV_ARCH=arm64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/ersatztv.tar.gz \
    "https://github.com/ErsatzTV/ErsatzTV/releases/download/v${VERSION}/ErsatzTV-v${VERSION}-linux-${ETV_ARCH}.tar.gz" && \
  tar xzf /tmp/ersatztv.tar.gz -C /app && \
  chmod 0755 /app/ErsatzTV && \
  mkdir -p /usr/share/licenses/ersatztv && \
  curl -fsSL -o /usr/share/licenses/ersatztv/LICENSE \
    "https://raw.githubusercontent.com/ErsatzTV/ErsatzTV/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/ersatztv.tar.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 8409

VOLUME /config
