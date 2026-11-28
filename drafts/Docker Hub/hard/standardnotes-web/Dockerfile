FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
WORKDIR /tmp
ENV HOME=/tmp \
    YARN_CACHE_FOLDER=/tmp/.yarn-cache
USER root

# UNVERIFIED: git ADD with '@' and '/' in the ref; fallback is
# git clone --depth 1 --branch "@standardnotes/web@${VERSION}" (needs git from apt)
ADD https://github.com/standardnotes/app.git#@standardnotes/web@${VERSION} /tmp/src

WORKDIR /tmp/src
# UNVERIFIED: Node 22 (.nvmrc 22.14.0) present in the base; yarn 3.2.1 from packageManager;
# the webpack step may need NODE_OPTIONS=--max-old-space-size=...
RUN corepack enable \
    && corepack prepare yarn@3.2.1 --activate \
    && yarn install --immutable \
    && yarn build:web

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

USER root
COPY --from=builder --chown=568:568 /tmp/src/packages/web/dist/ /usr/share/nginx/html
# UNVERIFIED: LICENSE file at the repo root
COPY --from=builder /tmp/src/LICENSE /usr/share/licenses/standardnotes-web/LICENSE

# Copy configuration files into container
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config

USER apps
COPY --chmod=0755 . /
WORKDIR /usr/share/nginx/html
