

FROM ghcr.io/trueforge-org/node:22.22@sha256:299642a3cabfc8e29c799b2cddbabc437a4cac6f8d4ca6caa52cf245ed4e464c AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.24.0@sha256:1a9b29e918f2848c1b510c16df2b68c21142601a0644bd62509d39a3b406d8f4
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY container-test.yaml /container-test.yaml
WORKDIR /usr/share/nginx/html
