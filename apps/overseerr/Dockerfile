FROM ghcr.io/trueforge-org/node:24.21@sha256:0a4a2fa98d1ad4ffe25454f056cc26647431d138b8e4c67ee4ea7f3d218813ff

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L -o /tmp/overseerr.tar.gz \
      "https://github.com/sct/overseerr/archive/refs/tags/v${VERSION}.tar.gz" && \
    mkdir -p /app && \
    tar xzf /tmp/overseerr.tar.gz -C /app --strip-components=1 && \
    cd /app && \
    CYPRESS_INSTALL_BINARY=0 yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn build && \
    yarn install --production --ignore-scripts --prefer-offline && \
    yarn cache clean && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf \
      /tmp/* \
      /app/src \
      /app/server \
      /app/.next/cache/*

USER apps
COPY --chmod=0755 . /
WORKDIR /app

EXPOSE 5055

CMD ["yarn", "start"]
