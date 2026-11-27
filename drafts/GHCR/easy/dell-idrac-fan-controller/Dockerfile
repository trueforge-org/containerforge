
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

ENV \
  HOME=/config \
  IDRAC_HOST=local \
  FAN_SPEED=5 \
  CPU_TEMPERATURE_THRESHOLD=auto \
  CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION=30 \
  CPU_TEMPERATURE_SOURCE=auto \
  CHECK_INTERVAL=5 \
  MAXIMUM_IPMI_UNREACHABLE_DURATION=60s \
  DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE=false \
  KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT=false \
  MONITORING_ONLY_MODE=false

# UNVERIFIED: package availability and candidate versions on ubuntu 26.04 (check apt-cache policy ipmitool); pin if they differ.
RUN echo "*** Installing IPMI and sensor tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ipmitool \
    lm-sensors \
    perl \
    libio-socket-ssl-perl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Upstream publishes no release assets, so the scripts come from the tag tarball.
# UNVERIFIED: no upstream checksum is published; a self-computed sha256 of this tarball must be pinned here before merge.
RUN echo "*** Fetching Dell iDRAC fan controller v${VERSION} ***" && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/src.tar.gz \
    "https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/src.tar.gz -C /app --strip-components=1 && \
  rm /tmp/src.tar.gz

# Upstream git mode is 644 for these scripts, so the image sets the execute bit.
# License files ship with the image, as upstream does.
RUN echo "*** Setting permissions and licenses ***" && \
  chmod 0755 /app/functions.sh /app/healthcheck.sh /app/Dell_iDRAC_fan_controller.sh /app/supervisor.sh && \
  install -d /usr/share/licenses/dell-idrac-fan-controller && \
  install -m 0644 /app/LICENSE /app/LICENSE-COMMERCIAL.md /app/NOTICE /usr/share/licenses/dell-idrac-fan-controller/ && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

# Nothing is persisted yet, but the repo rule keeps /config as the state path.
VOLUME /config
