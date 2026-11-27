FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# The release zip ships its own Node binary, so no separate Node runtime is installed.
# The bundle goes to /build because the upstream entrypoint hardcodes /build paths.
RUN echo "*** Installing WeKan ${VERSION} bundle ***" && \
  case "$TARGETARCH" in \
    amd64|arm64) WEKAN_ARCH="$TARGETARCH" ;; \
    *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
  esac && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip file libatomic1 && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /tmp/wekan && \
  cd /tmp/wekan && \
  curl -fsSL -O "https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-${WEKAN_ARCH}.zip" && \
  curl -fsSL -O "https://github.com/wekan/wekan/releases/download/v${VERSION}/wekan-${VERSION}-${WEKAN_ARCH}.zip.sha256sum" && \
  sha256sum -c "wekan-${VERSION}-${WEKAN_ARCH}.zip.sha256sum" && \
  unzip -q "wekan-${VERSION}-${WEKAN_ARCH}.zip" -d /tmp/wekan/unpacked && \
  cp -a /tmp/wekan/unpacked/bundle /build && \
  ln -s /build/node /usr/local/bin/node

# UNVERIFIED: the entrypoint and helper files come from the source tree at the tag (upstream copies them from releases/).
# UNVERIFIED: exact paths of recovery-bridge.mjs and db-ready.mjs in the tree.
RUN echo "*** Installing WeKan entrypoint files ***" && \
  mkdir -p /tmp/wekan-src && \
  curl -fsSL "https://github.com/wekan/wekan/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar xz -C /tmp/wekan-src --strip-components=1 && \
  install -m 0755 /tmp/wekan-src/releases/ferretdb/wekan-entrypoint.sh /build/wekan-entrypoint.sh && \
  install -m 0644 /tmp/wekan-src/releases/ferretdb/recovery-bridge.mjs /build/recovery-bridge.mjs && \
  install -m 0644 /tmp/wekan-src/releases/ferretdb/db-ready.mjs /build/db-ready.mjs && \
  install -D -m 0644 /tmp/wekan-src/LICENSE /usr/share/licenses/wekan/LICENSE && \
  chown -R apps:apps /build && chmod -R 755 /build && \
  rm -rf /tmp/*

ENV PORT=8080 \
  WRITABLE_PATH=/config/data \
  DEBUG=false \
  DDP_TRANSPORT=sockjs \
  HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /build
