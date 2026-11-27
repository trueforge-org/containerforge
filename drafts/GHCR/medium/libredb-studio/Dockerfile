FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Upstream uses a root entrypoint (gosu) and a node runtime user. This image
# runs as apps and does its own start in start.sh, so no privilege drop here.
# Upstream build-arg placeholders (JWT_SECRET_BUILD, ADMIN_PASSWORD_BUILD,
# USER_PASSWORD_BUILD) are intentionally not carried into the image.
ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    NODE_OPTIONS=--max-old-space-size=384 \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    WORKFLOW_LOCAL_DATA_DIR=/config/workflow

RUN \
  echo "**** map arch to upstream bundle name ****" && \
  case "${TARGETARCH}" in \
    amd64) bundle_arch=x64 ;; \
    arm64) bundle_arch=arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  echo "**** fetch standalone bundle and checksums ****" && \
  base="https://github.com/libredb/libredb-studio/releases/download/${VERSION}" && \
  bundle="libredb-studio-standalone-${VERSION}-linux-${bundle_arch}.tar.gz" && \
  mkdir -p /tmp/bundle /app && \
  curl -fsSL -o "/tmp/bundle/${bundle}" "${base}/${bundle}" && \
  curl -fsSL -o /tmp/bundle/SHA256SUMS "${base}/SHA256SUMS" && \
  echo "**** verify bundle ****" && \
  (cd /tmp/bundle && sha256sum -c --ignore-missing SHA256SUMS) && \
  echo "**** extract to /app (layout UNVERIFIED, see below) ****" && \
  tar xzf "/tmp/bundle/${bundle}" -C /app --strip-components=1 && \
  test -f /app/server.js && \
  echo "**** licence ****" && \
  mkdir -p /usr/share/licenses/libredb-studio && \
  curl -fsSL -o /usr/share/licenses/libredb-studio/LICENSE \
    "https://raw.githubusercontent.com/libredb/libredb-studio/${VERSION}/LICENSE" && \
  echo "**** remap upstream /app/data to /config/data (dangling until start.sh) ****" && \
  ln -s /config/data /app/data && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config

WORKDIR /app
