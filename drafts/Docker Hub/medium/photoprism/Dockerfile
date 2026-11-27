
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: runtime tool package names for Ubuntu 26.04 (upstream uses questing-slim, which ships these).
# Pin versions and record them in the PR body once the build runs.
RUN echo "*** Installing PhotoPrism runtime tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libvips-tools \
    libimage-exiftool-perl && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no upstream checksum is published. Compute SHA256 per arch and add a sha256sum check here before the first build.
RUN echo "*** Installing PhotoPrism ***" && \
  curl -o \
    /tmp/photoprism.tar.gz -L \
    "https://github.com/photoprism/photoprism/releases/download/${VERSION}/photoprism_${VERSION}-linux-${TARGETARCH}.tar.gz" && \
  mkdir -p /opt/photoprism && \
  tar xzf \
    /tmp/photoprism.tar.gz -C \
    /opt/photoprism --strip-components=1 && \
  chmod -R 755 /opt/photoprism && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/photoprism.tar.gz

# UNVERIFIED: tarball layout (--strip-components value, bin/photoprism path, assets/ location, LICENSE file) until listed with tar tzf.
# Ship the license under /usr/share/licenses/photoprism/ once the file name is confirmed.

ENV \
  PHOTOPRISM_ASSETS_PATH=/opt/photoprism/assets \
  PHOTOPRISM_STORAGE_PATH=/config/storage \
  PHOTOPRISM_ORIGINALS_PATH=/config/originals \
  PHOTOPRISM_IMPORT_PATH=/config/import \
  PHOTOPRISM_BACKUP_PATH=/config/storage/backups \
  PHOTOPRISM_LOG_FILENAME=/config/storage/photoprism.log \
  PHOTOPRISM_PID_FILENAME=/tmp/photoprism.pid \
  PHOTOPRISM_HTTP_HOST=0.0.0.0 \
  PHOTOPRISM_HTTP_PORT=2342 \
  PHOTOPRISM_DATABASE_DRIVER=sqlite \
  PHOTOPRISM_DISABLE_CHOWN=true \
  DO_NOT_TRACK=true \
  ORT_DISABLE_TELEMETRY=1 \
  TMPDIR=/tmp \
  XDG_CACHE_HOME=/tmp/.cache \
  MALLOC_ARENA_MAX=2

USER apps
COPY --chmod=0755 . /

EXPOSE 2342

VOLUME /config
WORKDIR /config
