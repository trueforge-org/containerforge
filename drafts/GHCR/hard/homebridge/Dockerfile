
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables.
# Plugins and npm state go to /config, not /var/lib or /opt.
# UNVERIFIED: the .deb's homebridge may not honour these paths.
ENV HOME=/config \
  npm_config_prefix=/config/npm \
  npm_config_cache=/tmp/npm \
  UIX_CUSTOM_PLUGIN_PATH=/config/node_modules \
  PATH=/config/npm/bin:/config/node_modules/.bin:$PATH

RUN \
  echo "**** check architecture ****" && \
  case "${TARGETARCH}" in \
    amd64|arm64) ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
  esac && \
  echo "**** install homebridge ****" && \
  apt-get update && \
  curl -fL -o \
    /tmp/homebridge.deb \
    "https://github.com/homebridge/homebridge-apt-pkg/releases/download/${VERSION}/homebridge_${VERSION#v}_${TARGETARCH}.deb" && \
  apt-get install -y --no-install-recommends \
    /tmp/homebridge.deb && \
  echo "**** license ****" && \
  mkdir -p \
    /usr/share/licenses/homebridge && \
  printf '%s\n' \
    "Homebridge (https://github.com/homebridge/homebridge) is licensed under Apache-2.0." \
    "UNVERIFIED: the license of homebridge-apt-pkg and of the bundled .deb components was not read." \
    > /usr/share/licenses/homebridge/NOTICE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# UNVERIFIED: the upstream image runs avahi-daemon for mDNS (ENABLE_AVAHI=1). It needs root and dbus,
# so it is not included here. HomeKit discovery over mDNS will not work from this image.
# UNVERIFIED: ffmpeg-for-homebridge is an alpine/musl build and does not run on ubuntu. Camera streaming needs a distro ffmpeg.

# copy files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8581
VOLUME /config
WORKDIR /config
ENTRYPOINT ["/start.sh"]
