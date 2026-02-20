FROM ghcr.io/trueforge-org/node:22.22@sha256:d02dc64dae5f37614c8f149fbddfe574f9f3d32e4538a274c98d36c7a2e98107

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
      /root/.cache \
      /app/src \
      /app/server \
      /app/.next/cache/*

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml
WORKDIR /app

EXPOSE 5055

CMD ["yarn", "start"]
