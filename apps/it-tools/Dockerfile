

FROM ghcr.io/trueforge-org/node:22.20@sha256:0d7011c0cfa0d010fa93c711ed870c7bc88a26588ef040629132939dd6816097 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:53096ab5104128d57235fd02f6dc61f1d87d738d6e3807bdc338518b3f620a74
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps:apps
WORKDIR /usr/share/nginx/html
