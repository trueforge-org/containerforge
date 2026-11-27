FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3db5983d5bd504865ac842efb282bcbdbd286adbc116fc18645ec3c433eba44a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# renovate: datasource=github-releases depName=itzg/mc-monitor
ARG MC_MONITOR_VERSION=1.18.3
# renovate: datasource=github-releases depName=itzg/rcon-cli
ARG RCON_CLI_VERSION=1.7.9
# renovate: datasource=github-releases depName=itzg/mc-image-helper
ARG MC_HELPER_VERSION=1.76.0

RUN \
  echo "**** install helper tools (checked against the checksums each release publishes) ****" && \
  case "${TARGETARCH}" in \
    amd64|arm64) ARCH="${TARGETARCH}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  mkdir -p \
    /tmp/helpers && \
  # UNVERIFIED: asset and checksum file names follow the plan; confirm them against each release on first build.
  curl -fL -o \
    /tmp/helpers/mc-monitor_${MC_MONITOR_VERSION}_linux_${ARCH}.tar.gz \
    "https://github.com/itzg/mc-monitor/releases/download/${MC_MONITOR_VERSION}/mc-monitor_${MC_MONITOR_VERSION}_linux_${ARCH}.tar.gz" && \
  curl -fL -o \
    /tmp/helpers/mc-monitor_checksums.txt \
    "https://github.com/itzg/mc-monitor/releases/download/${MC_MONITOR_VERSION}/checksums.txt" && \
  (cd /tmp/helpers && sha256sum --ignore-missing -c mc-monitor_checksums.txt) && \
  tar -xzf \
    /tmp/helpers/mc-monitor_${MC_MONITOR_VERSION}_linux_${ARCH}.tar.gz -C \
    /usr/bin mc-monitor && \
  curl -fL -o \
    /tmp/helpers/rcon-cli_${RCON_CLI_VERSION}_linux_${ARCH}.tar.gz \
    "https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VERSION}/rcon-cli_${RCON_CLI_VERSION}_linux_${ARCH}.tar.gz" && \
  curl -fL -o \
    /tmp/helpers/rcon-cli_checksums.txt \
    "https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VERSION}/rcon-cli_${RCON_CLI_VERSION}_checksums.txt" && \
  (cd /tmp/helpers && sha256sum --ignore-missing -c rcon-cli_checksums.txt) && \
  tar -xzf \
    /tmp/helpers/rcon-cli_${RCON_CLI_VERSION}_linux_${ARCH}.tar.gz -C \
    /usr/bin rcon-cli && \
  curl -fL -o \
    /tmp/helpers/mc-image-helper.tgz \
    "https://github.com/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}/mc-image-helper-${MC_HELPER_VERSION}.tgz" && \
  curl -fL -o \
    /tmp/helpers/mc-image-helper.tgz.sha256 \
    "https://github.com/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}/mc-image-helper-${MC_HELPER_VERSION}.tgz.sha256" && \
  (cd /tmp/helpers && sed "s|mc-image-helper-${MC_HELPER_VERSION}.tgz|mc-image-helper.tgz|" mc-image-helper.tgz.sha256 | sha256sum -c -) && \
  # UNVERIFIED: archive layout (bin/ path) to be confirmed on first build.
  tar -C \
    /usr/share -zxf /tmp/helpers/mc-image-helper.tgz && \
  ln -sf \
    /usr/share/mc-image-helper/bin/mc-image-helper /usr/bin/mc-image-helper && \
  chmod 0755 /usr/bin/mc-monitor /usr/bin/rcon-cli && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# TODO: the upstream scripts/ (run-bungeecord.sh, health.sh) were not fetched and are not copied yet; copy them
# into /usr/bin here once fetched at the pinned version. TODO: the LICENSE from upstream is not copied yet either.

# copy local files
USER apps
COPY --chmod=0755 . /

ENV RCON_PORT=25575 \
  MEMORY=512m \
  BUNGEE_HOME=/config

# ports and volumes
EXPOSE 25577 25565
VOLUME /config

WORKDIR /config
