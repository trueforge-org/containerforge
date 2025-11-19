

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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:055d7b2f2bd6f377f89d835eb5d5f4678786b30929720e04f802eda6f7219c3a
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
