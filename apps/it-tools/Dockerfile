

FROM ghcr.io/trueforge-org/node:24.16@sha256:054127dbde86feda9878cd8b6ccef97a4988a3f28f9e40bdc138c70cebb3f2ec AS builder
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

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:f5096c09d4a2b634b481c3ab7f7bfb576b264c63821f21ef6fe26cdb7f679f72
USER root
COPY --from=builder --chown=568:568 /tmp/dist/ /usr/share/nginx/html

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
