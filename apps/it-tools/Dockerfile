

FROM ghcr.io/trueforge-org/node:22.22@sha256:ec6290230c443c68f303007269be43b40a2260858c96cc9bf6e050c4668b38fd AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:d8eb51c16e45a64511cfcfae0bbfbe6c2a4bd018fa1c3cd59056531c999f4e23
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
WORKDIR /usr/share/nginx/html
