FROM ghcr.io/trueforge-org/node:24.15@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6

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
