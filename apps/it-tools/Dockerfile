

FROM ghcr.io/trueforge-org/node:22.20@sha256:8624b5123c437d4ede0454fc92e6b38ae6e14a5b722a3b75a26425632ee24633 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:c6b82820a3d851e97bff4aaaaaa1e2acee8e515604b28821a4c83a32824c0177
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
