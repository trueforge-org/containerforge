# ---------- BASE STAGE ----------
FROM ghcr.io/trueforge-org/node:22.22@sha256:ec6290230c443c68f303007269be43b40a2260858c96cc9bf6e050c4668b38fd AS base

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

EXPOSE 5055

CMD [ "npm", "start" ]
