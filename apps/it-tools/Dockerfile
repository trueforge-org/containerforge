

FROM ghcr.io/trueforge-org/node:22.22@sha256:57a1af013f040f6d66a0d1b53cc48dc6ac8b603c1384639fb3c4fe27252baf34 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:beb12e261144f8a599be7deaaedcaab05909869a7214e60c418a6ea386492183
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps:apps
WORKDIR /usr/share/nginx/html
