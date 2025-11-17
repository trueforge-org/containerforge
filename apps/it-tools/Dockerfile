

FROM ghcr.io/trueforge-org/node:22.20@sha256:56c028d92c9c7e5d29c1265fd0b615c9fbc4995cf5f6ef6007393c3030b4b749 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:ae8d25a43e178b9087d90e37bc36fad9cd3f04e3b8c4b647235b9520e1a79430
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
