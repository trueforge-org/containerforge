

FROM ghcr.io/trueforge-org/node:22.22@sha256:57a4a36bdf735ecfef262feb3354be695eadba8d4bd73138444dadfcce23da02 AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:1c8dcf45a1e32bc6d2fa78cf22391c1baccdd49d21c73a73abfa99c66f76e11f
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
