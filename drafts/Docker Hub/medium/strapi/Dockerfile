FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# UNVERIFIED: Strapi 5.63 needs Node 22 to 26. Check `node -v` in this base before relying on it.
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  npm_config_cache=/tmp/npm-cache

# The project is scaffolded and built at image build time. start.sh copies it to /config/app on first start.
# UNVERIFIED: create-strapi flags for a non-interactive scaffold on 5.63, confirm against the CLI.
RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python-is-python3 && \
  echo "*** Scaffolding Strapi ${VERSION} ***" && \
  npx --yes create-strapi@${VERSION} /app/strapi \
    --skip-cloud \
    --no-run \
    --use-npm && \
  cd /app/strapi && \
  npm run build && \
  echo "*** Saving license ***" && \
  mkdir -p /usr/share/licenses/strapi && \
  cp /app/strapi/node_modules/@strapi/strapi/LICENSE /usr/share/licenses/strapi/LICENSE && \
  echo "*** Cleaning Up ***" && \
  npm cache clean --force && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential python3 python-is-python3 && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* && \
  chown -R apps:apps /app/strapi && \
  chmod -R 755 /app/strapi

ENV \
  NODE_ENV=production \
  HOST=0.0.0.0 \
  PORT=1337

USER apps
COPY --chmod=0755 . /

EXPOSE 1337

VOLUME /config

WORKDIR /config
