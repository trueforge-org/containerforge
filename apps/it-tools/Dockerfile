

FROM ghcr.io/trueforge-org/node:22.22@sha256:4683c47e88074a64e0c954c469093f7ddfd7e71b553b37eff9cd96442fabb58b AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:7fae22df32b6ddcec0913bade894dedad1753c35723f4784320624527fcf1765
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

COPY container-test.yaml /container-test.yaml
USER apps
WORKDIR /usr/share/nginx/html
