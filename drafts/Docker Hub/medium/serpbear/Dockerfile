FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
# UNVERIFIED: no upstream checksum is published. Compute sha256 of the tag archive once and pin it in docker-bake.hcl. Until then the build fails.
ARG SERPBEAR_SHA256
USER root

# The build uses the same Node major as the runtime stage. Caches go to /tmp.
ENV \
  HOME=/tmp \
  NEXT_TELEMETRY_DISABLED=1 \
  npm_config_cache=/tmp/npm

RUN echo "*** Downloading SerpBear ${VERSION} ***" && \
  mkdir -p /build/serpbear && \
  curl -fsSL -o \
    /tmp/serpbear.tar.gz \
    "https://github.com/towfiqi/serpbear/archive/refs/tags/v${VERSION}.tar.gz" && \
  echo "${SERPBEAR_SHA256}  /tmp/serpbear.tar.gz" | sha256sum -c - && \
  tar xzf \
    /tmp/serpbear.tar.gz -C \
    /build/serpbear --strip-components=1 && \
  rm /tmp/serpbear.tar.gz && \
  echo "*** Building SerpBear ***" && \
  cd /build/serpbear && \
  rm -rf data __tests__ __mocks__ && \
  npm ci && \
  npm run build && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV \
  NODE_ENV=production \
  NEXT_TELEMETRY_DISABLED=1 \
  HOME=/tmp \
  npm_config_cache=/tmp/npm

# Next.js standalone output, then the static assets and the runtime files upstream copies.
COPY --from=build /build/serpbear/.next/standalone/ /app/
COPY --from=build /build/serpbear/.next/static /app/.next/static
COPY --from=build /build/serpbear/public /app/public
COPY --from=build /build/serpbear/node_modules/@babel/runtime /app/node_modules/@babel/runtime
COPY --from=build /build/serpbear/cron.js /app/cron.js
COPY --from=build /build/serpbear/email /app/email
COPY --from=build /build/serpbear/database /app/database
COPY --from=build /build/serpbear/.sequelizerc /app/.sequelizerc
COPY --from=build /build/serpbear/entrypoint.sh /app/entrypoint.sh
COPY --from=build /build/serpbear/LICENSE /usr/share/licenses/serpbear/LICENSE

# Runtime npm packages, pinned to the versions the upstream Dockerfile installs.
# The upstream image runs `npx sequelize-cli` and `npx concurrently` from /app.
RUN echo "*** Installing runtime packages ***" && \
  cd /app && \
  rm -f package.json && \
  npm init -y && \
  npm install --no-package-lock \
    croner@9.0.0 \
    cryptr@6.4.0 \
    dotenv@16.0.3 \
    @googleapis/searchconsole@1.0.5 \
    sequelize-cli@6.6.5 \
    concurrently@7.6.0 \
    @isaacs/ttlcache@1.4.1 && \
  npx concurrently --version && \
  npx sequelize-cli --version && \
  node -e "['croner','cryptr','dotenv','@googleapis/searchconsole','@isaacs/ttlcache'].forEach(m=>require(m))" && \
  echo "*** Redirecting data to /config ***" && \
  rm -rf /app/data && \
  ln -s /config/data /app/data && \
  echo "*** Setting permissions ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  npm cache clean --force && \
  rm -rf /tmp/* /root/.npm

USER apps
COPY --chmod=0755 . /

WORKDIR /app

EXPOSE 3000

VOLUME /config
