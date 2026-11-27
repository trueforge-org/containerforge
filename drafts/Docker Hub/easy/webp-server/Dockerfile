FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  GOCACHE=/tmp/go-build \
  WEBP_EXHAUST_PATH=/tmp/exhaust

# UNVERIFIED: libvips runtime package name on 26.04 (plan says libvips42t64). Confirm with apt-cache search '^libvips'.
# The libheif AOM plugins match the upstream runtime. Unpinned: the app version is not tied to these packages.
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    libvips42t64 \
    libheif-plugin-aomenc \
    libheif-plugin-aomdec; \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no checksum was confirmed for the release assets. Add a sha256 check once the release page is read.
RUN set -eux; \
  curl -fsSL -o /app/webp-server "https://github.com/webp-sh/webp_server_go/releases/download/${VERSION}/webp-server-linux-${TARGETARCH}"; \
  chmod 0755 /app/webp-server; \
  chown -R apps:apps /app; \
  mkdir -p /opt/pics /usr/share/licenses/webp-server; \
  chown apps:apps /opt/pics; \
  curl -fsSL -o /usr/share/licenses/webp-server/LICENSE "https://raw.githubusercontent.com/webp-sh/webp_server_go/${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 3333

VOLUME /config

WORKDIR /config
