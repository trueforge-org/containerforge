FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

USER root

ENV NODE_OPTIONS=--max_old_space_size=2048 \
    CONFIG_DIRECTORY=/config

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    NODE_ARCH=$(dpkg --print-architecture | sed 's/amd64/x64/') && \
    NODE_FILE=$(curl -fsSL https://nodejs.org/dist/latest-v20.x/SHASUMS256.txt | grep -o "node-v[0-9.]*-linux-${NODE_ARCH}\.tar\.xz" | head -1) && \
    curl -fsSL "https://nodejs.org/dist/latest-v20.x/${NODE_FILE}" | tar -xJ -C /usr/local --strip-components=1 --no-same-owner --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md && \
    node --version && \
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
