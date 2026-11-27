# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: the vendor publishes no checksum. Record sha256 per arch and version at implementation time.
ARG AGENT_SHA256_AMD64=""
ARG AGENT_SHA256_ARM64=""
USER root

# UNVERIFIED: package names on 26.04. ffmpeg is not installed here; decide after inspecting the vendor zip
# (it may ship its own FFmpeg).
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    libgdiplus \
    fontconfig \
    libva-drm2 \
    alsa-utils \
    tzdata && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing ispy Agent DVR ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) arch=Linux64; sha="${AGENT_SHA256_AMD64}" ;; \
    arm64) arch=LinuxARM64; sha="${AGENT_SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  [ -n "${sha}" ] || { echo "Agent checksum for ${TARGETARCH} is not set" >&2; exit 1; } && \
  v="$(echo "${VERSION}" | tr . _)" && \
  curl -fsSL -o /tmp/agent.zip \
    "https://files.ispyconnect.com/downloads/Agent_${arch}_${v}.zip" && \
  echo "${sha}  /tmp/agent.zip" | sha256sum -c - && \
  unzip -q /tmp/agent.zip -d /app && \
  chmod 0755 /app/Agent && \
  chmod -R a+rX /app && \
  rm -f /tmp/agent.zip

# Writable state lives in /config. Symlinks are created at build time, so nothing writes under /app at runtime.
# UNVERIFIED: the Agent resolves Media/ and Commands/ relative to its install directory.
RUN ln -s /config/Media /app/Media && \
  ln -s /config/Commands /app/Commands

# UNVERIFIED: vendor license and notice file names inside the zip. Copy whatever is shipped.
RUN mkdir -p /usr/share/licenses/ispy-agent-dvr && \
  (cp /app/*LICENSE* /app/*NOTICE* /usr/share/licenses/ispy-agent-dvr/ 2>/dev/null || true) && \
  printf '%s\n' "iSpy Agent DVR is proprietary vendor software (LicenseRef-Proprietary). See https://www.ispyconnect.com/." \
    > /usr/share/licenses/ispy-agent-dvr/NOTICE

ENV \
  HOME=/config \
  DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/dotnet \
  DOTNET_CLI_HOME=/tmp \
  MALLOC_TRIM_THRESHOLD_=100000 \
  DOTNET_gcServer=0

USER apps
COPY --chmod=0755 . /

EXPOSE 8090 3478/udp 50000-50100/udp

VOLUME /config
WORKDIR /app
