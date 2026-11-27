FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
USER root

ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    YARN_CACHE_FOLDER=/tmp/yarn

# VERSION is a commit SHA: upstream has no tags or releases.
RUN \
  echo "**** download troddit ${VERSION} ****" && \
  mkdir -p /app/troddit && \
  curl -fsSL -o /tmp/troddit.tar.gz \
    "https://github.com/burhan-syed/troddit/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/troddit.tar.gz -C /app/troddit --strip-components=1 && \
  rm /tmp/troddit.tar.gz

# UNVERIFIED: npm is present in python-node:3.15.2 and the Node version is >= 16.14 (Next 13 needs it).
# Upstream's alpine-only apk packages (libc6-compat, g++, make, py3-pip) are not needed on glibc.
# Dev dependencies are needed for `next build`, so install them first, then prune.
RUN \
  echo "**** build troddit ****" && \
  npm install -g yarn@1.22.19 && \
  cd /app/troddit && \
  NODE_ENV=development yarn install --frozen-lockfile --network-timeout 600000 && \
  yarn build && \
  yarn install --production --ignore-scripts --prefer-offline && \
  rm -rf /tmp/yarn

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    PORT=3000

# Standalone server tree, static assets and public files. Root-owned, so /app stays read-only at runtime.
COPY --from=build /app/troddit/.next/standalone /app/troddit/
COPY --from=build /app/troddit/.next/static /app/troddit/.next/static
COPY --from=build /app/troddit/public /app/troddit/public
COPY --from=build /app/troddit/next.config.js /app/troddit/next.config.js
# UNVERIFIED: LICENSE file name at the pinned commit. AGPL-3.0 is from the GitHub API.
COPY --from=build /app/troddit/LICENSE /usr/share/licenses/troddit/LICENSE

# Next writes its image and ISR cache under .next/cache. Point it at /tmp so the rootfs can stay read-only.
RUN \
  ln -s /tmp/next-cache /app/troddit/.next/cache && \
  chown -R root:root /app/troddit && \
  chmod -R 755 /app/troddit

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

WORKDIR /app/troddit
