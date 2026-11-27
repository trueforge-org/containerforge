# UNVERIFIED (draft): the plan uses ubuntu, not python-node, because this app needs Node 22 and no Python.
# Node 22 and Rust are installed in build stages. Upstream v2.17.0 uses rust:1.96 and node:22.23.4.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS monolith

ARG MONOLITH_VERSION=2.11.7
USER root
ENV CARGO_HOME=/tmp/cargo

# UNVERIFIED: cargo from the ubuntu archive may not match upstream's rust 1.96 (plan section 4, step 1).
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    cargo \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates && \
  cargo install --locked monolith --version "${MONOLITH_VERSION}" --root /opt/monolith && \
  rm -rf /var/lib/apt/lists/* /tmp/cargo

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS node

ARG NODE_VERSION=22.23.4
ARG TARGETARCH
USER root

# UNVERIFIED: Node 22 install method (plan section 4, step 3). The checksum comes from the upstream SHASUMS256.txt.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils && \
  rm -rf /var/lib/apt/lists/* && \
  case "${TARGETARCH}" in \
    amd64) NODE_ARCH=x64 ;; \
    arm64) NODE_ARCH=arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  cd /tmp && \
  curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" && \
  curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" && \
  grep -F "  node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" SHASUMS256.txt | sha256sum -c - && \
  mkdir -p /opt/node && \
  tar -xJf "node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" -C /opt/node --strip-components=1 && \
  rm -f /tmp/node-v* /tmp/SHASUMS256.txt

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS app

ARG VERSION
USER root
ENV PATH=/opt/node/bin:$PATH \
  HOME=/tmp \
  COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  PRISMA_HIDE_UPDATE_MESSAGE=1

COPY --from=node /opt/node /opt/node

# UNVERIFIED: no upstream checksum for the source tarball. It is pinned by tag only (plan section 1).
RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /tmp/src && \
  curl -fsSL "https://github.com/linkwarden/linkwarden/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1

WORKDIR /tmp/src

# UNVERIFIED: workspace names, the production prune and the build commands must match upstream v2.17.0 (plan section 4, step 5).
RUN corepack enable && \
  yarn workspaces focus linkwarden @linkwarden/web @linkwarden/worker && \
  yarn prisma:generate && \
  yarn web:build

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root
ENV PATH=/opt/node/bin:$PATH \
  NODE_ENV=production \
  PRISMA_HIDE_UPDATE_MESSAGE=1 \
  PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
  COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  NEXT_TELEMETRY_DISABLED=1 \
  HOME=/tmp \
  TZ=Etc/UTC

COPY --from=node /opt/node /opt/node
COPY --from=monolith /opt/monolith/bin/monolith /usr/local/bin/monolith
COPY --from=app /tmp/src/ /app/linkwarden/

# UNVERIFIED: Playwright CLI path and chromium-headless-shell system deps (plan sections 4 and 10).
RUN apt-get update && \
  /app/linkwarden/node_modules/.bin/playwright install --with-deps chromium-headless-shell && \
  rm -rf /var/lib/apt/lists/*

# Next.js writes its cache under /tmp at runtime, because /app is read-only. start.sh recreates /tmp/next-cache.
RUN mkdir -p /app/linkwarden/apps/web/.next && \
  rm -rf /app/linkwarden/apps/web/.next/cache && \
  ln -s /tmp/next-cache /app/linkwarden/apps/web/.next/cache && \
  install -D /app/linkwarden/LICENSE /usr/share/licenses/linkwarden/LICENSE && \
  chown -R apps:apps /app/linkwarden && \
  chmod -R 755 /app/linkwarden

USER apps
COPY --chmod=0755 . /

WORKDIR /app/linkwarden
EXPOSE 3000
VOLUME /config
