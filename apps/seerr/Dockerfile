FROM ghcr.io/trueforge-org/node:22.20@sha256:c57ff53b69edd1f3aae2d6e00ad2da65606b5dbc1fb42c78b4a73b44e58d099d

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048 \
    TMPDIR=/tmp/seerr-temp \
    PNPM_HOME="/pnpm" \
    PATH="$PNPM_HOME:$PATH"

# Enable Corepack and pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

# Download source and install dependencies
RUN curl -L -o /tmp/seerr.tar.gz \
      "https://github.com/seerr-team/seerr/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir -p /app/seerr && \
    tar xzf /tmp/seerr.tar.gz -C /app/seerr --strip-components=1

WORKDIR /app/seerr

# Install dependencies and build with pnpm
RUN CYPRESS_INSTALL_BINARY=0 pnpm install --frozen-lockfile --network-timeout 1000000 && \
    pnpm build && \
    pnpm install --prod --ignore-scripts --prefer-offline && \
    pnpm store prune && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /tmp/* /root/.cache /app/seerr/src /app/seerr/server /app/seerr/.next/cache/*

USER apps

EXPOSE 5055

CMD ["pnpm", "start"]
