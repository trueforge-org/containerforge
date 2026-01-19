

FROM ghcr.io/trueforge-org/node:22.20@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:81fa2e5f9ffa56e73300a15e080f2c2d1e09f36a9235882343661fd6f33210b3
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
