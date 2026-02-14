

FROM ghcr.io/trueforge-org/node:22.22@sha256:c0dc57295c677e6b1341544d1b89a2254ddebd07c55840c491be19b3bc3bec37 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:7064a39ba156191decef3e47eb47946e58fdb6b573aa3be8a2de69b7854e3db6
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps:apps
WORKDIR /usr/share/nginx/html
