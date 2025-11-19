

FROM ghcr.io/trueforge-org/node:22.20@sha256:5623d300a3daef923e94ff2a518468f381105886e35f8562868a3ceb7ebe39c9 AS builder
ARG VERSION
WORKDIR /tmp
ENV HOME=/tmp
USER root
ADD https://github.com/CorentinTh/it-tools.git#${VERSION} .
RUN npm install -g corepack@latest \
    && corepack enable  \
    && corepack prepare pnpm@latest --activate \
    && pnpm install --prefer-offline \
    && pnpm build

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:6d61361fa8d3b9a694d36ecc46d8f6d4793148139ac1dd74100c2fbe296696ba
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
