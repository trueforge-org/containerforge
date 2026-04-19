

FROM ghcr.io/trueforge-org/node:24.15@sha256:08ad119759c3d8f5682bca7c97d95575e1db19d79dbcf4004b0930ba9e08cc10 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:db8a17d268c9008c3fdc6dc977de004fbf152950abaf4c52ddc207b1cdb85a61
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
