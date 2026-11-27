FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

# build variables
ARG VERSION
ARG LOK_VERSION
ARG TARGETARCH
USER root

ENV CGO_ENABLED=0 \
    GOCACHE=/tmp/go-build \
    GOPATH=/tmp/go \
    HOME=/tmp

RUN \
  echo "**** fetch gotenberg source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/gotenberg-src.tar.gz \
    "https://github.com/gotenberg/gotenberg/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/gotenberg-src.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/gotenberg-src.tar.gz

RUN \
  echo "**** compile gotenberg ****" && \
  cd /tmp/src && \
  go mod download && \
  go mod verify && \
  go build \
    -o /tmp/gotenberg \
    -ldflags "-s -w -X 'github.com/gotenberg/gotenberg/v9/cmd.Version=${VERSION}'" \
    cmd/gotenberg/main.go

RUN \
  echo "**** fetch and verify lok ****" && \
  mkdir -p /tmp/lok && \
  cd /tmp/lok && \
  curl -fL -o lok.tar.gz \
    "https://github.com/gotenberg/lok/releases/download/v${LOK_VERSION}/lok_${LOK_VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fL -o checksums.txt \
    "https://github.com/gotenberg/lok/releases/download/v${LOK_VERSION}/checksums.txt" && \
  grep -F "  lok_${LOK_VERSION}_linux_${TARGETARCH}.tar.gz" checksums.txt > checksum-line.txt && \
  sha256sum -c checksum-line.txt && \
  tar xzf lok.tar.gz && \
  # UNVERIFIED: lok archive layout (binary at archive root, license file name) not inspected with tar tzf.
  install -m 0755 lok /tmp/lok-bin && \
  mkdir -p /tmp/lok-license && \
  (cp LICENSE* /tmp/lok-license/ 2>/dev/null || true)

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG LOK_VERSION
USER root

# Chromium is snap-only in the Ubuntu archive. UNVERIFIED: the xtradeb PPA is a third-party source; decide with maintainers.
RUN \
  echo "**** add xtradeb PPA for a real chromium package ****" && \
  add-apt-repository -y ppa:xtradeb/apps && \
  printf '%s\n' \
    'Package: *' \
    'Pin: release o=LP-PPA-xtradeb-apps' \
    'Pin-Priority: 100' \
    '' \
    'Package: chromium chromium-*' \
    'Pin: release o=LP-PPA-xtradeb-apps' \
    'Pin-Priority: 900' \
    > /etc/apt/preferences.d/xtradeb && \
  apt-get update && \
  # UNVERIFIED: package names for fonts and hyphen dictionaries must be checked on resolute during the first build.
  apt-get install -y --no-install-recommends \
    chromium \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress \
    libreoffice-draw \
    libreoffice-math \
    fonts-crosextra-carlito \
    fonts-crosextra-caladea \
    fonts-liberation \
    fonts-liberation2 \
    fonts-dejavu \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-noto-core \
    fonts-urw-base35 \
    hyphen-en-us && \
  rm -rf /var/lib/apt/lists/*
# UNVERIFIED: upstream pulls ~50 hyphen-* dictionaries; only hyphen-en-us is listed here, add the rest from the upstream Dockerfile before merge.

# gotenberg and lok binaries
COPY --from=build --chmod=0755 /tmp/gotenberg /usr/bin/gotenberg
COPY --from=build --chmod=0755 /tmp/lok-bin /usr/bin/lok

# files from the upstream source tree
COPY --from=build /tmp/src/build/fonts.conf /etc/fonts/conf.d/100-gotenberg.conf
COPY --from=build /tmp/src/build/chromium-hyphen-data /opt/gotenberg/chromium-hyphen-data
COPY --from=build /tmp/src/build/chromium-policies /etc/chromium/policies/managed
COPY --from=build --chmod=0755 /tmp/src/build/capture-version.sh /opt/gotenberg/capture-version.sh
# UNVERIFIED: upstream runs capture-version.sh at build time for chromium, libreoffice and lok; arguments not fetched.

# licenses
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gotenberg/LICENSE
COPY --from=build /tmp/lok-license/ /usr/share/licenses/lok/

ENV CHROMIUM_BIN_PATH=/usr/bin/chromium \
    CHROMIUM_HYPHEN_DATA_DIR_PATH=/opt/gotenberg/chromium-hyphen-data \
    LIBREOFFICE_BIN_PATH=/usr/lib/libreoffice/program/soffice.bin \
    LOK_BIN_PATH=/usr/bin/lok \
    GOTENBERG_VERSIONS_DIR_PATH=/opt/gotenberg/versions \
    OTEL_TRACES_EXPORTER=none \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none \
    HOME=/tmp \
    TMPDIR=/tmp \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000

VOLUME /config
