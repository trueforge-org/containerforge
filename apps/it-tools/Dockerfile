

FROM ghcr.io/trueforge-org/node:22.20@sha256:3345d6d3e3fb826b171518a83172dad4f4fc7f248933606daf72ed517053e693 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:48cf43659d6b401c805c2b873d1027e5539fc91bba0dc746eee4e920db5eebb5
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps:apps
WORKDIR /usr/share/nginx/html
