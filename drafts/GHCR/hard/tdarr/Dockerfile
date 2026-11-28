# Draft from plan.md (tdarr). Not built or tested. UNVERIFIED items are marked.
# Upstream is the LinuxServer jammy base with s6 and root. This image is built on the trueforge Ubuntu base
# and runs as apps. Tools come from the 26.04 archive, not from upstream builds (plan section 3).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Build date the Backblaze zips are named with (upstream DATE build arg). UNVERIFIED value for this version.
ARG DATE

USER root
# UNVERIFIED: package names on 26.04. x86 jellyfin-ffmpeg 6, the source-built HandBrake and Intel GPU drivers are dropped (plan section 10).
RUN echo "*** Installing Tdarr dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip ffmpeg handbrake-cli mkvtoolnix libtesseract-dev && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published upstream. The build relies on HTTPS to the bucket.
# UNVERIFIED: the zip names and whether this version exists in the dev/versions path.
RUN echo "*** Installing Tdarr ***" && \
  case "${TARGETARCH}" in \
    amd64) TDARR_ARCH=linux_x64 ;; \
    arm64) TDARR_ARCH=linux_arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  BASE_LINK="https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/${VERSION}" && \
  for MODULE in Tdarr_Server Tdarr_Node; do \
    curl -fL -o "/tmp/${MODULE}.zip" "${BASE_LINK}/${TDARR_ARCH}/${MODULE}_${DATE}.zip" && \
    mkdir -p "/app/${MODULE}" && \
    unzip -q "/tmp/${MODULE}.zip" -x '*.exe' -d "/app/${MODULE}" && \
    rm -f "/tmp/${MODULE}.zip"; \
  done && \
  chmod -R 755 /app/Tdarr_Server /app/Tdarr_Node

# /app is read-only at runtime. Upstream writes to /app/configs, /app/logs and /app/server, so these are symlinks into /config.
# UNVERIFIED: the binaries use these absolute paths. The plan calls for a knob if they do not.
RUN for d in configs logs server; do ln -s "/config/$d" "/app/$d"; done

# UNVERIFIED: the upstream LICENSE is not in the zips. Read it from the repo, then copy it to /usr/share/licenses/tdarr/.
# The licence is NOASSERTION on GitHub, so it is not set in docker-bake.hcl yet.

ENV WEB_UI_PORT=8265 \
  SERVER_PORT=8266 \
  UMASK=002 \
  TZ=Etc/UTC \
  HOME=/tmp/home \
  inContainer=true

USER apps
COPY --chmod=0755 . /

# The node connects out to the server and listens on no port of its own (docs run-compose), so no NODE_PORT is exposed.
EXPOSE 8265 8266
VOLUME /config
WORKDIR /app/Tdarr_Server
