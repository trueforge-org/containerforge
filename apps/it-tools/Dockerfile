# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/node:22.20@sha256:fc467b02bf83c210cd60142538dfc789ea86b4e6004b5c72de3876c2d3f3d89d AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:695d6912a50d5aaf8a1b3e7610874c1672c7a2f35fa9c1cda17d22790ad7eafb
USER root
COPY --from=builder --chown=nobody:nogroup /tmp/dist/ /usr/share/nginx/html
USER nobody:nogroup
WORKDIR /usr/share/nginx/html
