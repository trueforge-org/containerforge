

FROM ghcr.io/trueforge-org/node:22.22@sha256:d02dc64dae5f37614c8f149fbddfe574f9f3d32e4538a274c98d36c7a2e98107 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:d81e80c0c002ff532ebd6b727731c7c2032b94fc9024a16321cccb06a08be5fd
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
