# Python + Node base as used by apps/changedetection and other python-node apps.
# UNVERIFIED: the Node major in this base must satisfy the server package.json "engines" (upstream uses Node 26).
# If it does not, use option B in plan.md section 3.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS base

ARG VERSION

ENV HOME=/tmp \
    PNPM_STORE_DIR=/tmp/pnpm-store \
    COREPACK_HOME=/tmp/corepack

USER root

RUN npm install -g pnpm@11.28.9

# Fetch the tagged source. The tag archive is the only input; there is no prebuilt binary upstream.
FROM base AS source

ARG VERSION

RUN set -eux; \
    mkdir -p /src; \
    curl -fsSL -o /tmp/bookorbit-src.tar.gz \
      "https://github.com/bookorbit/bookorbit/archive/refs/tags/${VERSION}.tar.gz"; \
    tar -xzf /tmp/bookorbit-src.tar.gz -C /src --strip-components=1; \
    rm -f /tmp/bookorbit-src.tar.gz

# Client build, same pattern as upstream client-builder.
FROM base AS client-builder

WORKDIR /src
COPY --from=source /src/package.json /src/pnpm-workspace.yaml /src/pnpm-lock.yaml ./
COPY --from=source /src/patches ./patches
COPY --from=source /src/packages/types/package.json ./packages/types/package.json
COPY --from=source /src/client/package.json ./client/package.json
RUN pnpm install --filter client... --frozen-lockfile
COPY --from=source /src/packages ./packages
COPY --from=source /src/client ./client
RUN pnpm --config.verify-deps-before-run=false --filter client run build-only

# Server build, same pattern as upstream server-builder.
FROM base AS server-builder

WORKDIR /src
COPY --from=source /src/package.json /src/pnpm-workspace.yaml /src/pnpm-lock.yaml ./
COPY --from=source /src/patches ./patches
COPY --from=source /src/packages/types/package.json ./packages/types/package.json
COPY --from=source /src/server/package.json ./server/package.json
RUN pnpm install --filter server... --frozen-lockfile
COPY --from=source /src/packages ./packages
COPY --from=source /src/server ./server
RUN set -eux; \
    pnpm --config.verify-deps-before-run=false --filter server run build; \
    pnpm --config.allow-unused-patches=true --filter server deploy --prod --legacy /deploy; \
    cp -r /src/server/dist /deploy/dist; \
    # UNVERIFIED: destination of the migrations inside /deploy; upstream copies them, path not confirmed.
    mkdir -p /deploy/src/db; \
    cp -r /src/server/src/db/migrations /deploy/src/db/migrations

# Python venv for kobo-cloudscraper, built on the same base so the interpreter path matches runtime.
FROM base AS venv

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3-venv \
 && rm -rf /var/lib/apt/lists/*

COPY --from=source /src/server/requirements/kobo-cloudscraper.txt /tmp/kobo-cloudscraper.txt
RUN python3 -m venv /opt/bookorbit-python \
 && /opt/bookorbit-python/bin/pip install --no-cache-dir -r /tmp/kobo-cloudscraper.txt \
 && rm -f /tmp/kobo-cloudscraper.txt

# Runtime. Fresh copy of the base, so the pnpm/npm build tooling is not shipped.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS runtime

ARG VERSION

ENV NODE_ENV=production \
    PORT=3000 \
    NODE_MAX_OLD_SPACE_SIZE=2048 \
    APP_VERSION=${VERSION} \
    KOBO_CLOUDSCRAPER_PYTHON=/opt/bookorbit-python/bin/python \
    KOREADER_PLUGIN_PATH=/app/koreader-plugin/bookorbit.koplugin \
    HOME=/tmp

USER root

# Packages for PDF, DjVu and media handling. UNVERIFIED: Ubuntu package names; check on the first build.
# tini is not installed: start.sh uses exec, so node runs as PID 1 (see plan.md section 4 step 13).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      poppler-utils \
      djvulibre-bin \
      ffmpeg \
 && rm -rf /var/lib/apt/lists/*

COPY --from=venv /opt/bookorbit-python /opt/bookorbit-python
COPY --from=server-builder /deploy /app
COPY --from=client-builder /src/client/dist /app/public
# UNVERIFIED: source path of the client locales in the upstream tree.
COPY --from=client-builder /src/client/src/locales /app/locales
# UNVERIFIED: these three paths are relative to the repository root, as the upstream COPY lines read.
COPY --from=source /src/bin/kepubify /app/bin/kepubify
COPY --from=source /src/vendor/foliate /app/vendor/foliate
COPY --from=source /src/koreader-plugin/bookorbit.koplugin /app/koreader-plugin/bookorbit.koplugin
COPY --from=source /src/LICENSE /src/NOTICE /src/ADDITIONAL_TERMS.md /app/

# Build-time symlinks: the upstream paths /data and /books are kept, and point at the persistent /config volume.
# This runs as root at build time only. start.sh creates the directories.
RUN set -eux; \
    chmod +x /app/bin/kepubify/*; \
    mkdir -p /usr/share/licenses/bookorbit; \
    cp /app/LICENSE /app/NOTICE /app/ADDITIONAL_TERMS.md /usr/share/licenses/bookorbit/; \
    ln -s /config/data /data; \
    ln -s /config/books /books; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app
