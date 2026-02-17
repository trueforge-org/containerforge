

FROM ghcr.io/trueforge-org/node:22.22@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:2744563dac7125fc6542c7b9b06c9ba9a88fd992271bdc01b677d0c84280db53
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
WORKDIR /usr/share/nginx/html
