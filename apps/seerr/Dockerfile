# ---------- BASE STAGE ----------
FROM ghcr.io/trueforge-org/node:22.22@sha256:d02dc64dae5f37614c8f149fbddfe574f9f3d32e4538a274c98d36c7a2e98107 AS base

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048 \
   PNPM_HOME="/pnpm" \
   PATH="$PNPM_HOME:$PATH"

WORKDIR /app

# Fetch Seerr source and enable corepack for pnpm
RUN curl -L -o /tmp/seerr.tar.gz "https://github.com/seerr-team/seerr/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir -p /app && \
    tar xzf /tmp/seerr.tar.gz -C /app --strip-components=1

# ---------- CorePack stage ----------
FROM base AS corepack

RUN PNPM_MAJOR=$(jq -r '.engines.pnpm' package.json | sed 's/^[^0-9]*\([0-9]\+\).*$/\1/') \
    && echo "pnpm engine set to: $PNPM_MAJOR" \
    && corepack enable \
    && corepack prepare "pnpm@$PNPM_MAJOR" --activate


# ---------- PRODUCTION DEPS ----------
FROM corepack AS prod-deps

## TODO: Remove for next release
RUN sed -i 's#"prepare": "husky install"#"prepare": ""#' package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store CI=true pnpm install --prod --frozen-lockfile --prefer-offline

# ---------- BUILD STAGE ----------
FROM corepack AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 build-essential && \
    rm -rf /var/lib/apt/lists/* \
    && npm install --global node-gyp

# Install all dependencies & build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store CYPRESS_INSTALL_BINARY=0 pnpm install --frozen-lockfile --prefer-offline

RUN pnpm build \
    && pnpm store prune \
    && rm -rf .next/cache

# ---------- FINAL RUNTIME IMAGE ----------
FROM base

ENV NODE_ENV=production

WORKDIR /app

# Copy build results files
COPY --chown=apps:apps --from=builder /app/.next ./.next
COPY --chown=apps:apps --from=builder /app/dist ./dist

# Overwrite node_modules with production-only deps
COPY --chown=apps:apps --from=prod-deps /app/node_modules ./node_modules

# Fix permissions
RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml

EXPOSE 5055

CMD [ "npm", "start" ]
