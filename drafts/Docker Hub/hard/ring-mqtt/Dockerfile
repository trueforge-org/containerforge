FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG GO2RTC_VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  npm_config_cache=/tmp/.npm \
  TMPDIR=/tmp \
  XDG_CACHE_HOME=/tmp/.cache

# UNVERIFIED: Node major of the python-node base (upstream uses Node 22); check `node -v` and package.json engines in the first build.
# Upstream apk list is: tar xz git bash curl jq tzdata mosquitto-clients. Only jq, tzdata and mosquitto-clients are carried over here.
# UNVERIFIED: no checksum is published for the source tarball or go2rtc assets; pin sha256 values once they are confirmed.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    jq \
    mosquitto-clients \
    tzdata && \
  echo "**** fetch and install ring-mqtt ****" && \
  mkdir -p /app/ring-mqtt && \
  curl -fL -o /tmp/ring-mqtt.tar.gz \
    "https://github.com/tsightler/ring-mqtt/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/ring-mqtt.tar.gz -C /app/ring-mqtt --strip-components=1 && \
  cd /app/ring-mqtt && \
  npm install --omit=dev --cache /tmp/.npm && \
  echo "**** install go2rtc ****" && \
  curl -fL -o /usr/local/bin/go2rtc \
    "https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC_VERSION}/go2rtc_linux_${TARGETARCH}" && \
  chmod 0755 /usr/local/bin/go2rtc && \
  echo "**** install licenses ****" && \
  mkdir -p /usr/share/licenses/ring-mqtt && \
  cp /app/ring-mqtt/LICENSE /usr/share/licenses/ring-mqtt/ && \
  curl -fL -o /usr/share/licenses/ring-mqtt/go2rtc-LICENSE \
    "https://raw.githubusercontent.com/AlexxIT/go2rtc/v${GO2RTC_VERSION}/LICENSE" && \
  echo "**** compatibility and permissions ****" && \
  ln -s /config /data && \
  chmod -R a+rX /app && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 55123 8554
VOLUME /config
WORKDIR /app/ring-mqtt
CMD ["/start.sh"]
