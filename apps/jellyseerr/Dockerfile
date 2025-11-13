FROM ghcr.io/trueforge-org/node:22.20@sha256:c57ff53b69edd1f3aae2d6e00ad2da65606b5dbc1fb42c78b4a73b44e58d099d

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048 \
    TMPDIR=/tmp/seerr-temp \
    PNPM_HOME="/pnpm" \
    PATH="$PNPM_HOME:$PATH"

RUN curl -L -o /tmp/seerr.tar.gz "https://github.com/seerr-team/seerr/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir -p /app/seerr && \
    tar xzf /tmp/seerr.tar.gz -C /app/seerr --strip-components=1

WORKDIR /app/seerr

RUN PNPM_MAJOR=$(jq -r '.engines.pnpm' package.json | sed 's/^[^0-9]*\([0-9]\+\).*$/\1/') && \
    echo "pnpm engine set to: $PNPM_MAJOR" \
    && corepack enable \
    && corepack prepare "pnpm@$PNPM_MAJOR" --activate

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies using BuildKit cache
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    CI=true \
    CYPRESS_INSTALL_BINARY=0 \
    pnpm install --frozen-lockfile --fetch-timeout=1000000

# Build project
RUN pnpm build

# Install production dependencies only
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    CI=true \
    pnpm install --prod --ignore-scripts --prefer-offline

RUN pnpm store prune && \
    chown -R apps:apps /app && chmod -R 755 /app
