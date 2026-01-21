

FROM ghcr.io/trueforge-org/node:22.20@sha256:faab5a63db1426eff0e065ab6635c739155986e89b248f1fd160babcd2c6fbe0 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:648e1c33d1d31bd235f783976375783d2db10399f66250b6b6ab4f9b3d2efcc3
USER root
RUN mkdir -p /tmp/nginx-temp \
    && chown -R 568:568 /tmp/nginx-temp
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html
USER apps:apps
WORKDIR /usr/share/nginx/html
