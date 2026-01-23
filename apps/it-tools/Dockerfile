

FROM ghcr.io/trueforge-org/node:22.20@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:8f8eca958a6442bb760182401cb8921640b6b72c8f5fabb0c07b5dc1c13e3cb4
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
