

FROM ghcr.io/trueforge-org/node:24.15@sha256:5d401829d5061483016ca171db4e1d540fc07ba5e4b8722a3b5f272c2b69ffae AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:4350f44a010dc49110c9664e6e216352b8ce80ad5d68d8f2bf3a00b378b2498f
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
