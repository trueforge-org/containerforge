FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS builder

# set version label
ARG VERSION
ARG SIMPLE_MODE=true
USER root

# Node major in python-node is UNVERIFIED against upstream's node:26 build image.
ENV HUSKY=0 \
    NODE_OPTIONS=--max-old-space-size=3072 \
    SIMPLE_MODE=${SIMPLE_MODE} \
    SITE_URL=https://www.bentopdf.com \
    ALLOW_INDEXING=false \
    HOME=/tmp \
    npm_config_cache=/tmp/npm

RUN \
  echo "**** fetch source at tag ****" && \
  mkdir -p /src && \
  curl -fsSL -o /tmp/bentopdf-src.tar.gz \
    "https://github.com/alam00000/bentopdf/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/bentopdf-src.tar.gz -C /src --strip-components=1 && \
  cd /src && \
  echo "**** build static site (no checksum is published upstream) ****" && \
  npm ci && \
  npm run build:with-docs && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    /src/node_modules

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# set version label
ARG VERSION
USER root

COPY --from=builder --chown=568:568 /src/dist/ /usr/share/nginx/html
COPY --from=builder /src/LICENSE /usr/share/licenses/bentopdf/LICENSE

# Copy configuration files into container
COPY --chmod=755 ./ /

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /usr/share/nginx/html
