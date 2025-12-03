

FROM ghcr.io/trueforge-org/node:22.20@sha256:78823e5b699725f4858e3a14d9240c8b1abd527cda46ff33b5028b11f034975d AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:dbc5ffba7c41845a29135d81d3d1063bada2f7a6938d7836a8cec88a0db925fc
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
