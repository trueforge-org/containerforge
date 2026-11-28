FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

# build variables
ARG VERSION
ARG SET_PROPERTY_VERSION
ARG SET_PROPERTY_SHA256
ARG MC_SERVER_RUNNER_VERSION
ARG MC_SERVER_RUNNER_SHA256
ARG MC_MONITOR_VERSION
ARG MC_MONITOR_SHA256
USER root

# UNVERIFIED: fetched from the upstream tag without a checksum; plan says vendor or pin these
RUN \
  echo "**** fetch upstream entry script, property definitions and licence ****" && \
  mkdir -p /tmp/bedrock /defaults /usr/share/licenses/minecraft-bedrock && \
  curl -fL -o /tmp/bedrock/bedrock-entry.sh \
    "https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/${VERSION}/bedrock-entry.sh" && \
  curl -fL -o /tmp/bedrock/bds-property-definitions.json \
    "https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/${VERSION}/property-definitions.json" && \
  curl -fL -o /usr/share/licenses/minecraft-bedrock/LICENSE \
    "https://raw.githubusercontent.com/itzg/docker-minecraft-bedrock-server/${VERSION}/LICENSE"

# helper binaries, amd64 only (see docker-bake.hcl image-all)
RUN \
  echo "**** fetch helper binaries ****" && \
  curl -fL -o /tmp/set-property.tgz \
    "https://github.com/itzg/set-property/releases/download/${SET_PROPERTY_VERSION}/set-property_${SET_PROPERTY_VERSION}_linux_amd64.tar.gz" && \
  echo "${SET_PROPERTY_SHA256}  /tmp/set-property.tgz" | sha256sum -c - && \
  tar -xzf /tmp/set-property.tgz -C /usr/local/bin set-property && \
  curl -fL -o /tmp/mc-server-runner.tgz \
    "https://github.com/itzg/mc-server-runner/releases/download/${MC_SERVER_RUNNER_VERSION}/mc-server-runner_${MC_SERVER_RUNNER_VERSION}_linux_amd64.tar.gz" && \
  echo "${MC_SERVER_RUNNER_SHA256}  /tmp/mc-server-runner.tgz" | sha256sum -c - && \
  tar -xzf /tmp/mc-server-runner.tgz -C /usr/local/bin mc-server-runner && \
  curl -fL -o /tmp/mc-monitor.tgz \
    "https://github.com/itzg/mc-monitor/releases/download/${MC_MONITOR_VERSION}/mc-monitor_${MC_MONITOR_VERSION}_linux_amd64.tar.gz" && \
  echo "${MC_MONITOR_SHA256}  /tmp/mc-monitor.tgz" | sha256sum -c - && \
  tar -xzf /tmp/mc-monitor.tgz -C /usr/local/bin mc-monitor && \
  chmod 0755 /usr/local/bin/set-property /usr/local/bin/mc-server-runner /usr/local/bin/mc-monitor && \
  rm -f /tmp/set-property.tgz /tmp/mc-server-runner.tgz /tmp/mc-monitor.tgz

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# UNVERIFIED: base may already ship jq and unzip; drop this step if so
RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    jq \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# add entry scripts, helpers and licence
COPY --from=buildstage /tmp/bedrock/bedrock-entry.sh /etc/bedrock-entry.sh
COPY --from=buildstage /tmp/bedrock/bds-property-definitions.json /etc/bds-property-definitions.json
COPY --from=buildstage /usr/local/bin/set-property /usr/local/bin/set-property
COPY --from=buildstage /usr/local/bin/mc-server-runner /usr/local/bin/mc-server-runner
COPY --from=buildstage /usr/local/bin/mc-monitor /usr/local/bin/mc-monitor
COPY --from=buildstage /usr/share/licenses/minecraft-bedrock/ /usr/share/licenses/minecraft-bedrock/

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 19132/tcp 19132/udp 19133/udp

ENV HOME=/config \
    TMPDIR=/tmp \
    DOWNLOAD_DIR=/tmp/bedrock-downloads \
    SERVER_PORT=19132 \
    SERVER_PORT_V6=19133 \
    ENABLE_BDS_V6BIND_FIX=false \
    USE_BOX64=false

WORKDIR /config
VOLUME /config
