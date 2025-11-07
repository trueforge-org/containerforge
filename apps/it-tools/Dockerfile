# syntax=docker/dockerfile:1

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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:6739023e1bcfb221dffb4029271d1110e3ed387517c6f7c73aa0d17bfe059e56
USER root
COPY --from=builder --chown=nobody:nogroup /tmp/dist/ /usr/share/nginx/html
USER nobody:nogroup
WORKDIR /usr/share/nginx/html
