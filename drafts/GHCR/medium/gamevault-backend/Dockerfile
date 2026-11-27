FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# build variables
ARG VERSION
USER root

# UNVERIFIED: no published checksum for the tag tarball; record the SHA-256 in the PR
RUN \
  echo "**** fetch gamevault-backend source ${VERSION} ****" && \
  mkdir -p /tmp/src && \
  curl -fL "https://github.com/Phalcode/gamevault-backend/archive/refs/tags/${VERSION}.tar.gz" \
    | tar -xz -C /tmp/src --strip-components=1

# build with pnpm (upstream pins pnpm 11; exact patch version UNVERIFIED)
ENV PNPM_HOME=/tmp/pnpm \
    NPM_CONFIG_PREFIX=/tmp/npm-global \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PATH=/tmp/npm-global/bin:/tmp/pnpm:$PATH

RUN \
  echo "**** install pnpm and build ****" && \
  npm i -g pnpm@11 && \
  cd /tmp/src && \
  pnpm install --frozen-lockfile && \
  pnpm run build && \
  echo "**** reduce to production dependencies ****" && \
  pnpm install --prod --frozen-lockfile

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# UNVERIFIED: whether the backend needs psql or pg_dump; install postgresql-client only if it does and the base lacks it
# add gamevault-backend build output and production dependencies
RUN \
  mkdir -p /app/gamevault-backend /usr/share/licenses/gamevault-backend
COPY --from=build /tmp/src/dist /app/gamevault-backend/dist
COPY --from=build /tmp/src/node_modules /app/gamevault-backend/node_modules
COPY --from=build /tmp/src/package.json /app/gamevault-backend/package.json
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gamevault-backend/LICENSE

# add local files
USER apps
COPY --chmod=0755 . /

ENV NODE_ENV=production \
    SERVER_PORT=8080 \
    HOME=/tmp \
    TZ=Etc/UTC

# ports and volumes
EXPOSE 8080

WORKDIR /app/gamevault-backend
VOLUME /config
