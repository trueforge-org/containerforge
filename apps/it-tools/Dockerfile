

FROM ghcr.io/trueforge-org/node:22.20@sha256:a542ce53c1e8f0dd5791c383265f05b830b99292abca1e17cfe8b0f7fdd26650 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:d965e4482c4cc6d20f0122a38da523da102a81d01a57d0d912c1fb03b31086e0
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
