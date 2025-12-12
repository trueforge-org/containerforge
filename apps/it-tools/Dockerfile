

FROM ghcr.io/trueforge-org/node:22.20@sha256:e7943f0fd226d9a2db62d2a65612ee5f9c95528661913f546ab15fc08d53ccab AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:9c203341248031c8f2532a63476b4709bc65716868fe7c84b7fcf4daaf18a4bb
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
