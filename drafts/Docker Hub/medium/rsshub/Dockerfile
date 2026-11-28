FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# renovate: datasource=github-tags depName=DIYgod/RSSHub versioning=loose
ARG VERSION=v2026.11.28-8772.gcbce479
ARG TARGETARCH

ENV \
    NODE_ENV=production \
    PORT=1200 \
    LD_PRELOAD=libjemalloc.so.2 \
    npm_config_cache=/tmp/npm \
    PNPM_HOME=/tmp/pnpm

USER root
WORKDIR /app

# UNVERIFIED: apt package versions; pin them once checked against the image. git is kept only as upstream does it.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        libjemalloc2 \
    && rm -rf /var/lib/apt/lists/*

# Source is built from the tag tarball. The release has no binary assets and no published checksum.
RUN set -eux; \
    curl -fsSL -o /tmp/rsshub.tar.gz \
        "https://github.com/DIYgod/RSSHub/archive/refs/tags/${VERSION}.tar.gz"; \
    tar -xzf /tmp/rsshub.tar.gz -C /app --strip-components=1; \
    rm -f /tmp/rsshub.tar.gz

# Pin pnpm to the version declared in the source's packageManager field (not corepack@latest).
RUN set -eux; \
    PNPM_VERSION="$(node -p "require('/app/package.json').packageManager.split('@')[1]")"; \
    npm install -g "pnpm@${PNPM_VERSION}"

# Build with the lockfile. Browser download is skipped here and handled below.
RUN set -eux; \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 pnpm install --frozen-lockfile; \
    pnpm build; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        PLAYWRIGHT_BROWSERS_PATH=/app/node_modules/.cache/ms-playwright \
            pnpm exec playwright install --with-deps chromium; \
    fi; \
    pnpm prune --prod; \
    rm -rf /tmp/*

# UNVERIFIED: arm64 Chromium. Ubuntu's chromium package is a snap wrapper, so no arm64 browser is installed here.
# Chromium feeds on arm64 need a package source to be chosen before CHROMIUM_EXECUTABLE_PATH can point at it.

RUN install -Dm644 /app/LICENSE /usr/share/licenses/rsshub/LICENSE \
    && chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /
WORKDIR /app

EXPOSE 1200
VOLUME /config
