

FROM ghcr.io/trueforge-org/node:22.22@sha256:332d8270315296b8b7756a9a277c3739a51616a870b0540c777f5aabf4b0ec18 AS builder
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

USER apps
WORKDIR /usr/share/nginx/html
