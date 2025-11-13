FROM ghcr.io/trueforge-org/node:22.20@sha256:c57ff53b69edd1f3aae2d6e00ad2da65606b5dbc1fb42c78b4a73b44e58d099d

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048 \
    TMPDIR=/tmp/seerr-temp

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L -o /tmp/seerr.tar.gz \
      "https://github.com/seerr-team/seerr/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir -p /app/seerr && \
    tar xzf /tmp/seerr.tar.gz -C /app/seerr --strip-components=1 && \
    cd /app/seerr && \
    CYPRESS_INSTALL_BINARY=0 yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline && \
    yarn cache clean && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf \
      /tmp/* \
      /root/.cache \
      /app/seerr/src \
      /app/seerr/server \
      /app/seerr/.next/cache/*

USER apps
WORKDIR /app/seerr

EXPOSE 5055

CMD ["yarn", "start"]
